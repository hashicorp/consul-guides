# Listing service

This service returns a listing retrieved from a JSON DB. This application will be automatically deployed by the terraform code in this demo, please see the [README for running the demo](terraform/aws/README.md). The application can also be deployed as a standalone service for testing, these steps are provided below.

## Steps for standalone deployment

### Start a local mongo instance for testing with username `mongo` and password `mongo`:
```
mkdir ~/listing-data
sudo docker run -d -p 27017:27017 -v ~/listing-data:/data/db \
  -e MONGO_INITDB_ROOT_USERNAME=mongo \
  -e MONGO_INITDB_ROOT_PASSWORD=mongo \
  --name mongodb mongo
```

### Install Node.js and the listing application:
```
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
cd /tmp
git clone https://github.com/hashicorp/consul-guides.git
cd consul-guides && git fetch && git checkout add-service-configuration && cd ..
sudo cp -r /tmp/consul-guides/service-configuration/service-configuration-demo/application/listing-service /opt
cd /opt/listing-service
npm install
npm install node-vault
sudo chown -R ubuntu:ubuntu /opt/listing-service
```

### Run the application
```
DB_URL='localhost' DB_PORT=27017 DB_COLLECTION=listings username=mongo password=mongo \
DB_NAME=bbthe90s COL_NAME=listings version=1.0 LISTING_ADDR=0.0.0.0 LISTING_PORT=8000 \
/usr/bin/node /opt/listing-service/server.js
```

### Access the application
```
curl localhost:8000/listing
```
