#! /bin/bash

CREDS=$1
PROJ=$2
REGION=$3

if [ -z "$CREDS" ]; then
    echo "Please enter GCP credentials file:"
    read CREDS
fi  

if [ -z "$PROJ" ]; then
    echo "Please enter project name:"
    read CREDS
fi  

if [ -z "$REGION" ]; then
    echo "Please enter region:"
    read CREDS
fi  

#if [ ( -z "$CREDS" ) || ( -z "$PROJ" ) || ( -z "$REGION"  )  ]
#    echo "Please ensure you have entered GCP credentials, project name and region."
#    exit 1
#fi  

echo "Downloading Consul"
curl https://releases.hashicorp.com/consul/1.1.0/consul_1.1.0_linux_amd64.zip -o binaries/consul.zip
unzip binaries/consul.zip -d binaries/

echo "Building western server image..."
#GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
 GCP_ZONE=$REGION DC_NAME=west NODE_TYPE=server \
 packer build -force server.json

echo "Building eastern server image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
 GCP_ZONE=$REGION DC_NAME=east NODE_TYPE=server \
 packer build -force server.json

echo "Building western client image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
 GCP_ZONE=$REGION DC_NAME=west NODE_TYPE=client \
 packer build -force client.json

echo "Building eastern client image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
 GCP_ZONE=$REGION DC_NAME=east NODE_TYPE=client \
 packer build -force client.json