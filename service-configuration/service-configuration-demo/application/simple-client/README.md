# Web client service

This service displays results retrieved from the products and listing API. This application will be automatically deployed by the terraform code in this demo, please see the [README for running the demo](terraform/aws/README.md). The application can also be deployed as a standalone service for testing, these steps are provided below.

## Steps for standalone deployment

### Install pre-requisites and the web_client application:
```
pip3 install flask
pip3 install pymongo

# Create application directory and create a PID file:
rm -rf /home/ubuntu/src && mkdir -p /home/ubuntu/src
cd /tmp
git clone https://github.com/hashicorp/consul-guides.git
# PR only step:
cd consul-guides && git fetch && git checkout add-service-configuration && cd ..
cp -r /tmp/consul-guides/service-configuration/service-configuration-demo/application/simple-client /home/ubuntu/src
chown -R ubuntu:ubuntu /home/ubuntu/src/simple-client
```

### Run the application
```
export LISTING_URI=http://listing.service.consul:8000
export PRODUCT_URI=http://product.service.consul:5000
export IS_CONNECT=0
/usr/bin/python3 /home/ubuntu/src/simple-client/client.py
```

### Access the application
In a new terminal window, please issue:
```
curl localhost:8080
```
