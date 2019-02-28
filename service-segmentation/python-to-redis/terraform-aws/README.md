### Consul Connect guide for Python to Redis - AWS EC2 instances

This guide consists of a python client microservice called `clientms`, connecting to an upstream `redis` service. We will instantiate both services to demonstrate the Consul Connect managed proxy. The steps outlined below are applicable to a 2 node Consul cluster running on Amazon AWS EC2 instances. The client and server microservices will be instantiated on different VMs.

```
+--AWS VPC---------------------------------------------------------------------------+
+--AWS Availability Zone ------------------------------------------------------------+
+--AWS Subnet 172.20.20.0/24 --------------------------------------------------------+

    +-EC2 instance ------------+                   +-EC2 instance --------------+
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
In order the perform the steps in this guide, you will need to have [Terraform](https://www.terraform.io/downloads.html) installed in your machine, or access to [Terraform Enterprise](https://www.terraform.io/docs/enterprise/index.html). The steps below assume you are running `terraform` locally.

### Provision cluster and deploy services
1. `git clone` this repo into a host machine.
2. From a terminal `cd` into this subdirectory: `cd terraform-aws`.
  - Optional: set the `CONSUL_DEMO_VERSION` environment variable in [setup/consul_n1_setup.sh] and [setup/consul_n2_setup.sh] (defaults to 1.2.2).
3. Export the following environment variables to setup AWS provider:
```
export AWS_ACCESS_KEY_ID=<your_aws_access_key_id>
export AWS_SECRET_ACCESS_KEY=<your_aws_access_key_id>
```
4. (Optional) Set any terraform variables if needed with `TF_VAR_` prefix. The `variables.tf` file contains all variables that can be set.
  - E.g. the following command will set the `owner` terraform variable (used as an AWS tag) to the current shell user: `export TF_VAR_owner = "$(whoami)"`

5. Issue Terraform commands to provision resources. Once `terraform apply` completes, we are ready to start the demo.
```
terraform init
terraform plan
terraform apply
```

### Consul setup review
Terraform has already setup a non-HA Consul cluster using the 2 EC2 instances. Both services have also been started and registered with Consul. This information can be viewed via the Consul UI or CLI:

#### Consul UI:
- View the Consul UI in a web browser @ URL: `terraform output consul_ui_url`
  - Click on the **Service** Tab to see the 2 services: `clientms`, `redis` and their proxies: `clientms-proxy`, `redis-proxy`.
  - Click on the **Nodes** Tab to see the 2 nodes:
    - Click on **n1** to see clientms tcp check and Proxy.
    - Click on **n2** to see redis tcp check and Proxy.    

#### Consul CLI:
- Lets start a terminal and log into n1:
```
rm -f consul_demo_id_rsa
terraform output ssh_private_key > consul_demo_id_rsa
chmod 400 consul_demo_id_rsa
export n1_host=$(terraform output node_1_public_dns)
ssh -i consul_demo_id_rsa ubuntu@${n1_host}
```

- View the Consul cluster: `consul members`
- Query the Consul API to review microservice definitions via CLI:   
```
curl localhost:8500/v1/catalog/service/clientms | jq .
curl localhost:8500/v1/catalog/service/redis | jq .
```

### Test the client microservice
The client microservice is a simple Python Flask application that is a Redis client. It will try to connect to a Redis host and port configurated via Environment variables: `REDIS_HOST` and `REDIS_PORT`. These values were supplied to the microservice when we started the Docker container instance.  

1. Lets check if traffic between clientms and Redis is allowed: `consul intention check clientms redis`.  
It should say `Allowed`, therefore we can test the service by performing write and read operations to Redis:  
```
curl localhost:5000/
curl localhost:5000/write/cat
curl localhost:5000/read/key-#
```

2. (Optional) Interact with the application via web browser @ URL: `terraform output clientms_url`
  - Test the service by performing write and read operations to Redis:
    - `<url>/write/piedpiper`
    - `<url>/key-#``

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
The Client microservice by itself uses a plain TCP connection without TLS. However because we routed this request over Consul connect, TLS Encryption in transit was handled for us without requiring any special configuration. We can view Consul's default certificate setup using the following commands:  
```
curl localhost:8500/v1/connect/ca/roots
curl localhost:8500/v1/connect/ca/configuration
```

### Cleanup
Run the following commands to remove variables and resources:
```
terraform destroy
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset n1_host
rm -f consul_demo_id_rsa
```
