import os

from flask import Flask
from flask import render_template
import requests
import upstream

app = Flask(__name__)

def get_products():
    try:
        products = requests.get(upstream.get_product_addr())
        print(products.status_code)
        print(products.text)
        return products.json()
    except requests.ConnectionError as e:
        return []

def get_listings():
    try:
        listings = requests.get(upstream.get_listing_addr())
        print(listings.status_code)
        print(listings.text)
        return listings.json()
    except requests.ConnectionError as e:
        return []

def get_listings_metadata():
    try:
        listings_meta = requests.get(upstream.get_listing_meta())
        print(listings_meta.text)
        return listings_meta.json()
    except requests.ConnectionError as e:
        return []

def get_products_metadata():
    try:
        products_meta = requests.get(upstream.get_product_meta())
        print(products_meta.text)
        return products_meta.json()
    except requests.ConnectionError as e:
        return []

@app.route('/healthz')
def healthz():
    return 'OK'

@app.route('/')
def index():
    products = get_products()
    listings = get_listings()
    is_connect = os.environ.get('IS_CONNECT', 0)
    return render_template('index.html', prod_list=products, listings_list=listings,
            products_meta=get_products_metadata(), listings_meta=get_listings_metadata(), is_connect=is_connect)

if __name__ == '__main__':
      app.run(host='0.0.0.0', port=8080)
