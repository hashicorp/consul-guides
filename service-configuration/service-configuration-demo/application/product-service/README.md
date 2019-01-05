# Product service

This service returns a set of products retrieved from a JSON DB. This application will be automatically deployed by the terraform code in this demo, please see the [README for running the demo](terraform/aws/README.md). The application can also be deployed as a standalone service for testing, these steps are provided below.

## Steps for standalone deployment

### Start a local mongo instance for testing (if necessary):
```
mkdir ~/product-data
sudo docker run -d -p 27017:27017 -v ~/product-data:/data/db --name mongodb mongo
```
### Install pre-requisites and the listing application:
```
pip3 install flask
pip3 install pymongo
cd /tmp
git clone https://github.com/hashicorp/consul-guides.git
cd consul-guides && git fetch && git checkout add-service-configuration && cd ..
sudo cp -r /tmp/consul-guides/service-configuration/service-configuration-demo/application/product-service /opt
cd /opt/product-service
sudo chown -R ubuntu:ubuntu /opt/product-service
```

### Run the application
```
FLASK_APP=product.py flask run
```

### Access the application
```
curl localhost:5000/product
```
