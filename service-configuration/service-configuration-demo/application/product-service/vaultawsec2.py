#!/usr/bin/env python
import logging.handlers
import os

import hvac
import re
import json
import requests
from requests.exceptions import RequestException


logger = logging.getLogger(__name__)

VAULT_URL = os.getenv("VAULT_ADDR", "https://127.0.0.1:8200")
VAULT_CERTS = ("/etc/vault.d/ssl/bundle.crt", "/etc/vault.d/ssl/vault.key")
TOKEN_NONCE_PATH = os.getenv("WP_VAULT_TOKEN_NONCE_PATH", "/tmp/.vault-token-meta-nonce")
EC2_METADATA_URL_BASE = "http://169.254.169.254"
AWS_EC2_NONCE = os.environ.get("AWS_EC2_NONCE")
AWS_EC2_ROLE = os.environ.get("AWS_EC2_ROLE")

def load_aws_ec2_pkcs7_string(metadata_url_base=EC2_METADATA_URL_BASE):
    """
    Requests an ec2 instance's pkcs7-encoded identity document from the EC2 metadata service.
    :param metadata_url_base: IP address for the EC2 metadata service.
    :return: string, pkcs7-encoded identity document from the EC2 metadata service
    """
    metadata_pkcs7_url = "{base}/latest/dynamic/instance-identity/pkcs7".format(base=metadata_url_base)
    logger.debug("load_aws_ec2_pkcs7_string connecting to %s" % metadata_pkcs7_url)

    response = requests.get(url=metadata_pkcs7_url)
    response.raise_for_status()

    pcks7 = response.text.replace("\n", "")

    return pcks7


def load_aws_ec2_nonce_from_disk(token_nonce_path=TOKEN_NONCE_PATH):
    """
    Helper method to load a previously stored "token_meta_nonce" returned in the
    initial authorization AWS EC2 request from the current instance to our Vault service.
    :param token_nonce_path: string, the full filesystem path to a file containing the instance's
        token meta nonce.
    :return: string, a previously stored "token_meta_nonce"
    """
    logger.debug("Attempting to load vault token meta nonce from path: %s" % token_nonce_path)
    try:
        with open(token_nonce_path, "rb") as nonce_file:
            nonce = nonce_file.readline()
    except IOError:
        logger.warning("Unable to load vault token meta nonce at path: %s" % token_nonce_path)
        nonce = None

    logger.debug("Nonce loaded: %s" % nonce)
    return nonce


def write_aws_ec2_nonce_to_disk(token_meta_nonce, token_nonce_path=TOKEN_NONCE_PATH):
    """
    Helper method to store the current "token_meta_nonce" returned from authorization AWS EC2 request
    from the current instance to our Vault service.
    :return: string, a previously stored "token_meta_nonce"
    :param token_meta_nonce: string, the actual nonce
    :param token_nonce_path: string, the full filesystem path to a file containing the instance's
        token meta nonce.
    :return: None
    """
    logger.debug("Writing nonce {0} to file {1}".format(token_meta_nonce, token_nonce_path))
    with open(token_nonce_path, "w") as nonce_file:
        nonce_file.write(token_meta_nonce)


def auth_ec2(vault_client, pkcs7=None, nonce=None, role=None, mount_point="aws", store_nonce=True):
    """
    Helper method to authenticate to vault using the "auth_ec2" backend.
    :param vault_client: hvac.Client
    :param pkcs7: pkcs7-encoded identity document from the EC2 metadata service
    :param nonce: string, the nonce retruned from the initial AWS EC2 auth request (if applicable)
    :param role: string, the role/policy to request. Defaults to the current instance's AMI ID if not provided.
    :param mount_point: string, the path underwhich the AWS EC2 auth backend is provided
    :param store_nonce: bool, if True, store the nonce received in the auth_ec2 response on disk for later use.
        Especially useful for automated secure introduction.
    :param kwargs: dict, remaining arguments blindly passed through by this lookup module class
    :return: None
    """
    if pkcs7 is None:
        logger.debug("No pkcs7 argument provided to auth_ec2 backend.")
        logger.debug("Attempting to retrieve information from EC2 metadata service.")
        pkcs7 = load_aws_ec2_pkcs7_string()

    if nonce is None:
        logger.debug("No nonce argument provided to auth_ec2 backend.")
        logger.debug("Attempting to retrieve information from disk.")
        nonce = load_aws_ec2_nonce_from_disk()

    auth_ec2_resp = vault_client.auth_ec2(
        pkcs7=pkcs7,
        nonce=nonce,
        role=role,
        use_token=True,
        mount_point=mount_point
    )

    if store_nonce and "metadata" in auth_ec2_resp.get("auth", dict()):
        token_meta_nonce = auth_ec2_resp["auth"]["metadata"].get("nonce")
        if token_meta_nonce is not None:
            logger.debug("token_meta_nonce received back from auth_ec2 call: %s" % token_meta_nonce)
            write_aws_ec2_nonce_to_disk(token_meta_nonce)
        else:
            logger.warning("No token meta nonce returned in auth response.")

    return auth_ec2_resp

def load_vault_token(resp):
    """
    Retrieves the Vault token from AWS EC2 Authentication
    """
    token = None

    if 'auth' in resp and 'client_token' in resp['auth']:
        token = resp['auth']['client_token']
        
    else: #Try searching using regex 
        resp_str = json.dumps(resp)
        searchObject = re.search(r'client_token[\"\'\s:]*([\w]*)[\"\'],',resp_str)
        if searchObject and len(searchObject.groups()) > 0:
            token = searchObject.groups(1)
        else:
            logger.warn("Could not extract client_token from ec2 auth response")
    
    logger.debug("returning token: %s" % token)
    return token

def get_vault_client(vault_url=VAULT_URL, certs=VAULT_CERTS, verify_certs=True, ec2_role=None):
    """
    Instantiates a hvac / vault client.
    :param vault_url: string, protocol + address + port for the vault service
    :param certs: tuple, Optional tuple of self-signed certs to use for verification with hvac's requests
    :param verify_certs: bool, if True use the provided certs tuple for verification with hvac's requests.
        If False, don't verify SSL with hvac's requests (typically used with local development).
    :param ec2_role: str, Name of the Vault AWS auth backend role to use when retrieving a token (if applicable)
    :return: hvac.Client
    """
    logger.debug("Retrieving a vault (hvac) client...")
    if verify_certs:
        # We use a self-signed certificate for the vault service itself, so we need to include our
        # local ca bundle here for the underlying requests module.
        os.environ["REQUESTS_CA_BUNDLE"] = "/etc/ssl/certs/ca-certificates.crt"
        vault_client = hvac.Client(
            url=vault_url,
            cert=certs,
        )
    else:
        vault_client = hvac.Client(
            url=vault_url,
            verify=False,
        )

    resp = auth_ec2(vault_client,nonce=AWS_EC2_NONCE,role=ec2_role)
    logger.debug("Vault response from AWS EC2 Auth: %s" % resp)

    token = load_vault_token(resp)
    vault_client.token = token
    
    return vault_client

def get_mongo_creds(product_config):
    result = None
    logging.basicConfig(level=logging.DEBUG)
    vault_client = get_vault_client(verify_certs=False,ec2_role=product_config['AWS_EC2_ROLE'])

    if vault_client.is_authenticated():
        resp = vault_client.read(product_config['VAULT_SECRET_PATH'])
        logger.debug("obtained response of type: %s and content: %s" % (type(resp),resp))

        if 'data' in resp:
            result = (resp['data']['username'],resp['data']['password'])
        else:
            logger.warn("Could not find data in response, returning None")

    else:
        logger.warn("vault client is not authenticated, returning None")
    
    return result

if __name__ == "__main__":
    print(get_mongo_creds())
