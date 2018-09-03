## Consul Connect guide - local VMs (Vagrant)

This guide consists of a python client micro-service called `clientms`, connecting to an upstream `redis` service. We will instantiate both services to demonstrate the Consul connect proxy. The steps outlined below are applicable to a 2 node Consul cluster running on Vagrant VMs. The client and server services will be instantiated on different VMs.


```
+--------------------------+                   +----------------------------+
|                          |                   |                            |
| consul_n1                |                   | consul_n2                  |
| 172.20.20.10             |                   | 172.20.20.11               |
|                          |                   |                            |
| clientms (port: 5000)    |                   | Redis service (port: 6379) |
|   +                      |                   |    ^                       |
|   |                      |                   |    |                       |
|   |                      |                   |    |                       |
|   v                      |                   |    |                       |
| Local bind port: 6400    | TLS Mutual Auth   |    +                       |
| Consul Connect Proxy <-----------------------> Consul Connect Proxy       |
| Consul Agent (Server)    |                   | Consul Agent (Client)      |
|                          |                   |                            |
+--------------------------+                   +----------------------------+
```

### Pre-requisites
In order the perform the steps in this guide, you will need to have [Vagrant](https://www.vagrantup.com/) installed in your machine.

### Provision cluster and deploy services
1. `git clone` this repo into a host machine.
2. From a terminal `cd` into this subdirectory: `cd consul-connect-guide-vagrant`.
  - Optional: set the `CONSUL_DEMO_VERSION` environment variable in Vagrantfile or terminal (defaults to 1.2.2).
3. Run `vagrant up` to start the VMs we will use for this guide.

### Consul setup review
The `Vagrantfile` has setup a non-HA Consul cluster using the 2 Vagrant VMs. Both services have also been started and registered with Consul. This information can be viewed using the commands below:

- SSH into n1 from terminal: `vagrant ssh n1`.  
- Verify that the consul cluster has 2 members: `consul members`
- Query the Consul API to review microservice definitions:   
```
curl localhost:8500/v1/catalog/service/clientms
curl localhost:8500/v1/catalog/service/redis  
```

### Test the client microservice
The client microservice is a simple Python Flask application that is a Redis client. It will try to connect to a Redis host and port configurated via Environment variables: `REDIS_HOST` and `REDIS_PORT`. These values were supplied to the microservice when we started the Docker container instance.  

Lets check if traffic between clientms and Redis is allowed: `consul intention check clientms redis`.  
It should say `Allowed`, therefore we can test the service by performing write and read operations to Redis:  
```
curl localhost:5000/
curl localhost:5000/write/cat
curl localhost:5000/read/key-#  
```

### Test Intentions
The above test should be successful since by default Consul connect allows communication among services. Lets create a deny intention and perform the test again:  

```
consul intention create -deny clientms redis
curl localhost:5000/
```
We now observe some errors. We can review the logs from client microservice using the command: `docker logs clientms`. We should be seeing some `Connection Reset` errors.  
- Lets check again if traffic between clientms and Redis is allowed: `consul intention check clientms redis`. It should say `Deny`.
- We can view all intentions using the command: `curl localhost:8500/v1/connect/intentions`.

### View certificates for encryption in transit
The Client microservice by itself uses a plain TCP connection without TLS. However because we routed this request over Consul connect, TLS Encryption in transit was handled for us without requiring any special configuration. We can view default certificate setup using the following commands:
```
curl localhost:8500/v1/connect/ca/roots
curl localhost:8500/v1/connect/ca/configuration
```

### Cleanup
Run the following commands to remove vagrant VMs:
```
vagrant destroy
```
