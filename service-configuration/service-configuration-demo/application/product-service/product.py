import logging.handlers
from flask import Flask
from flask import jsonify
from pymongo import MongoClient
from vaultawsec2 import get_mongo_creds

import yaml
import os
import datetime
import traceback

logger = logging.getLogger(__name__)

mongo_creds = None
product_config = None

def connect_to_db():
    # Load Database endpoint from config file
    global product_config
    db_addr = product_config['DB_ADDR']
    db_port = int(product_config['DB_PORT'])

    # Load Database credentials from Vault using AWS EC2 Authentication
    # get_mongo_creds() function is defined in vaultawsec2.py
    global mongo_creds
    mongo_creds = get_mongo_creds(product_config)

    if mongo_creds: # Use credentials from Vault AWS EC2 Authentication
        db_username = mongo_creds[0]
        db_pw = mongo_creds[1]

    if not db_addr or not db_port: # try default connection settings
        client = MongoClient()
    else:
        if not db_pw or not db_username: # try connection without authentication
            client = MongoClient(db_addr, db_port)
        else: # connect with authentication
            client = MongoClient(db_addr, db_port, username=db_username, password=db_pw)

    return client

# these can be seeded into the DB for testing if necessary
prods = [{ 'inv_id': 1, 'name':'jncos', 'cost':35.57, 'img':None},
         { 'inv_id': 2, 'name':'denim vest', 'cost':22.50, 'img':None},
         { 'inv_id': 3, 'name':'pooka shell necklace', 'cost':12.37, 'img':None},
         { 'inv_id': 4, 'name':'shiny shirt', 'cost':17.95, 'img':None}]

app = Flask(__name__)

@app.route("/product", methods=['GET'])
def get_products():
    res = get_products_from_db()
    return jsonify(res)

@app.route("/product/metadata", methods=['GET'])
def get_metadata():
    global mongo_creds
    db_username = mongo_creds[0]
    db_pw = mongo_creds[1]

    # Mask password string except last 4 digits
    m = ['X'] * (len(db_pw)-4)
    mask = ''.join(m)
    meta_pw = mask + db_pw[len(db_pw)-4:]

    global product_config
    metadata_dict = {
     "version": product_config['version'],
     "DB_USER": db_username,
     "DB_PW": meta_pw
    }

    return jsonify(metadata_dict)

@app.route("/product/healthz", methods=['GET'])
def get_health():
    return "OK"

def get_products_from_db():
    global product_config

    db_name = product_config['DB_NAME']
    col_name = product_config['COL_NAME']

    try:
        return [rec for rec in db_client[db_name][col_name].find({}, {'_id': False})]

    except Exception as e:
        logger.warn(str(e))
        logger.warn("Renewing credentials and retrying once -->")
        traceback.print_exc()

        global db_client
        db_client = connect_to_db()
        return [rec for rec in db_client[db_name][col_name].find({}, {'_id': False})]

if __name__ == '__main__':

    try: # Try to load the product yaml configuration file
        config_file_path = None
        default_path = "/opt/product-service/config.yml"

        config_file = os.environ.get("PRODUCT_CONFIG_PATH")
        if config_file and os.path.isfile(config_file): # Try to load from path specified by environment variable
            config_file_path = config_file

        elif os.path.isfile(default_path): # Try to load from default path
            config_file_path = default_path

        else: # Try to load from current directory
            config_file_path = "config.yml"
            logger.info('Could not find config file in ${PRODUCT_CONFIG_PATH} or default path. Trying to load from current directory.')

        logger.info("Loading config file from path: %s" % config_file_path)
        with open(config_file_path, 'r') as ymlfile:
            product_config = yaml.load(ymlfile)["product"]
            ymlfile.close()

        # Obtain new Database client:
        db_client = connect_to_db()

        # Start Flask:
        app.run(host=product_config['PRODUCT_ADDR'], port=product_config['PRODUCT_PORT'])

    except Exception as e:
        logger.error(str(e))
