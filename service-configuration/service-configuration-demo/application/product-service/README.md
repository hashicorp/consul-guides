# Product service

This service returns a list of products retrieved from a JSON DB

## Instructions

##### Start a local mongo instance for testing (if necessary):
```
mkdir ~/product-data
docker run -d -p 27017:27017 -v ~/product-data:/data/db --name mongodb mongo
```

##### Python prep and flask server:
```
pip install flask
pip install pymongo
```

##### Run the server
```
DB_ADDR='localhost' DB_PORT=27018 FLASK_APP=product.py \
DB_NAME=bbthe90s COL_NAME=products PRODUCT_PORT=1234 flask run
```
