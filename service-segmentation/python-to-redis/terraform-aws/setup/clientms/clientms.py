from dns import resolver
import yaml
import redis
import random
import os
from flask import Flask
app = Flask(__name__)

#Welcome page
@app.route('/')
def main():
    html = 'Client service is accessible. To send a server microservice request try: /write/<value>, /read/<key> or /test'
    html = html + "\nTesting Redis server connection:\n"
    r , s = getserverconnection()
    html = html + s + "\n"

    if r is not None:
        r.exists("test")
        html = html + "Test connection to redis service successful.\n"
    else:
        html = html + "Test connection to redis service failed, please check logs for more details.\n"

    return html

#Write a string to Redis
@app.route('/write/<value>')
def write(value):
    r , s = getserverconnection()
    if r is not None:
        key = "key-" + str(random.randint(1,100))
        r.set(key, value)
        return key + "\n"
    else:
        return s

#Read from string from Redis
@app.route('/read/<key>')
def read(key):
    r , s = getserverconnection()
    if r is not None:
        value = r.get(key)
        if value is not None:
            return str(value) + "\n"
        else:
            return "<null>\n"
    else:
        return s + "\n"


#Provides a connection to Redis service
def getserverconnection():
    serverms_host = None
    serverms_port = None
    s1 = ""

    #First try with environment variables:
    if "REDIS_HOST" in os.environ and "REDIS_PORT" in os.environ:
        serverms_host = os.environ['REDIS_HOST']
        serverms_port = int(os.environ['REDIS_PORT'])
        s1 = 'Using environment variable redis host and port: %s:%s' % (serverms_host, serverms_port)
        print(s1)

    else: #Load from config file
        config_file_name = "config.yml"
        try:
            with open(config_file_name, 'r') as ymlfile:
                cfg = yaml.load(ymlfile)
                ymlfile.close()

            serverms_host = cfg['redis_host']
            serverms_port = int(cfg['redis_port'])
            s1 = 'Using config file redis host and port: %s:%s' % (serverms_host, serverms_port)
            print(s1)

        except Exception as e:
            s = 'Encountered file issue: ' + str(e)
            print(s)
            return (None,s)

    try:
        #Attempt connection to Redis
        print('Attempting Redis connection to: %s:%s' % (serverms_host, serverms_port))
        r = redis.Redis(host=serverms_host,port=serverms_port)
        return (r, s1)

    except Exception as e:
        s = s1 + '\nEncountered connection issue: ' + str(e)
        print(s)
        return (None,s)
