# Running the Demo

## Overview

This terraform code will spin up a simple three-tier web application: a web frontend `web_client`, 2 APIs: `listing` and `product`, and a MongoDB instance. Please view the main [README](../../README.md) for an Architecture overview.

### Demo steps
- [Pre-requisites](README.md#pre-requisites)
- [Build AMIs using Packer (Optional)](README.md#build-amis-using-packer-optional-)
- [Provisioning](README.md#provisioning)
- [Service Configuration](README.md#service-configuration)
  - [Service Configuration for Product Service with Consul Template](README.md#service-configuration-for-product-service-with-consul-template)
  - [Service Configuration for Listing Service with Envconsul](README.md#service-configuration-for-listing-service-with-envconsul)
- [Dynamic Credentials](README.md#dynamic-credentials)
  - [Dynamic Credentials for Listing Service with Envconsul](README.md#dynamic-credentials-for-listing-service-with-envconsul)
  - [Dynamic Credentials for Product Service with Vault API](README.md#dynamic-credentials-for-product-service-with-vault-api)

### Pre-requisites

1. A machine with git and ssh installed
2. The appropriate [Terraform binary](https://www.terraform.io/downloads.html) for your system. This demo was tested using terraform `v0.11.10`.
3. An AWS account with credentials which allow you to deploy infrastructure.
4. An already-existing [Amazon EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) in the desired region.

### Build AMIs using Packer (optional)
Please see [README.md](../../packer/README.md) from `packer` directory.

### Provisioning

#### Terraform steps
 1. Please open a terminal window and run the commands:
```
export AWS_ACCESS_KEY_ID="<your access key ID>"
export AWS_SECRET_ACCESS_KEY="<your secret key>"
export AWS_DEFAULT_REGION="us-east-1"
```
    Replace `<your access key ID>` with your AWS Access Key ID and `<your secret key>` with your AWS Secret Access Key (see [Access Keys (Access Key ID and Secret Access Key)](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) for more help). *NOTE*: Currently, the Packer-built AMIs are only in `us-east-1`.

2. Please run: `git clone https://github.com/hashicorp/consul-guides.git`  
   _[PR only step: `cd consul-guides && git fetch && git checkout add-service-configuration && cd ..`]_
3. `cd consul-guides/service-configuration/service-configuration-demo/terraform/aws/`
4. `cp terraform.auto.tfvars.example terraform.auto.tfvars`
5. Edit the `terraform.auto.tfvars` file:
  1. Change the `project_name` so that it is **unique to you**. It can have lowercase alphaneumeric and hyphen characters.
  2. In the `hashi_tags` line change `owner` to be your email address. **Important**: The combination of `project_name` and `owner` must be unique within your AWS organization. They are used to set Consul cluster membership.

  3. Change `ssh_key_name` to the name of an already existing SSH Keypair in AWS.
  4. Optionally, please specify your own IP address (`["<your_ip_address>/32"]`)  for the variable `security_group_ingress`. This is only needed if you want to access Vault and/or Consul UI. You can visit [http://whatismyip.akamai.com](http://whatismyip.akamai.com) on your browner, or run the command `curl -s http://whatismyip.akamai.com` from terminal to find your IP address.

4. Save your changes to the `terraform.auto.tfvars` file
5. Run `terraform init`, when you see: "Terraform has been successfully initialized!":
6. Run `terraform apply`, if everything looks good please reply `yes` to the confirmation prompt.

Once the command prompt returns, the demo will be ready within a minute.

### Access the application

 1. Run `terraform output webclient-lb` and point a web browser at the value returned.

### Service Configuration

1. On the web browser "Product metadata" and "Listing metadata" sections, note the version string for both Product and Listing service. It should say `'version': 1.0`.
2. From a terminal session SSH into a web_client server:
   - `terraform output webclient_servers`
   - `ssh -i <your_pem_file> ubuntu@<first_dns_returned>`
   When asked `Are you sure you want to continue connecting (yes/no)?` answer `yes` and hit enter

3. View the application version strings stored in Consul distributed KV store:
```
consul kv get product/config/version
consul kv get listing/config/version
```
Try adding `-detailed` to see additional kv metadata: `consul kv get -detailed product/config/version`

4. Consul UI (optional): If you have setup the Terraform variable `security_group_ingress` in your terraform.auto.tfvars, you can view these in the Consul UI.
  - To construct the URL for Consul UI you can issue the command `terraform output consul_servers` and use any DNS name with port 8500: `"http://<consul_server>:8500/ui"`
  - Click on "Key/Value", click "product" or "listing", then click on "config" to view configuration data.

#### Service Configuration for Product Service with Consul Template
  - On your terminal, exit out of the web_client SSH session and issue: `terraform output product_api_servers`
  - `ssh -i <your_pem_file> ubuntu@<first_dns_returned>`
  - Consul Template manages the lifecycle for this application. Issue the command `systemctl status product.service` and you will see `Main PID: 1642 (consul-template)`, and a process hierarchy as below (your PID #s will be different):
  ```
 ├─1642 /usr/local/bin/consul-template -config /opt/product-service/product_consul_template.hcl
 └─1662 /usr/bin/python3 /opt/product-service/product.py
  ```
  Hit `q` to exit if needed. Consul Template is triggered as a daemon service from the systemd unit file: `/lib/systemd/system/product.service`

  - Lets view product service configuration data in Consul:
  ```
  consul kv get -recurse product/config
  ```
  - Consul Template reads the above values and renders an application configuration file: `/opt/product-service/config.yml`. Display the contents of this file: `cat /opt/product-service/config.yml`. Product service reads this file from [product.py](../../application/product-service/product.py) (see comment: _`# Try to load the product yaml configuration file`_).
  - The configuration for Consul Template can be seen here: `cat /opt/product-service/product_consul_template.hcl`. The following line tells Consul Template where to find the input template:
  ```
  source = "/opt/product-service/config.ctpl"
  ```
  - If you display the above file it will show where Consul Template pulls the configuration from: `cat /opt/product-service/config.ctpl`.
  - You will notice a set of `keyOrDefault` entries. This tells Consul Template to look for the specified key in Consul's distributed key/value store, then render the corresponding value. If the specified key is not found, then Consul Template will use the default value.
  - Lets modify the version string to `1.5`, then check `config.yml` and the metadata endpoint.
  ```
  consul kv put product/config/version 1.5
  cat /opt/product-service/config.yml
  curl -s product.service.consul:5000/product/metadata
  ```
You will see version 1.5 in `config.yml` and metadata. Upon updating the version string, Consul Template rendered the config file and restarted product service immediately.

#### Service Configuration for Listing Service with Envconsul
  - On your terminal, exit out of the Product SSH session and issue: `terraform output listing_api_servers`
  - `ssh -i <your_pem_file> ubuntu@<first_dns_returned>`
  - Envconsul manages the lifecycle for this application. Issue the command `systemctl status listing.service` and you will see `Main PID: 1656 (envconsul)`, and a process hierarchy as below (your PID #s will be different):
  ```
  ├─1656 /usr/local/bin/envconsul -config /opt/listing-service/listing_envconsul.hcl
  └─4866 /usr/bin/node /opt/listing-service/server.js
  ```
  Hit `q` to exit if needed. Envconsul is triggered as a daemon service from the systemd unit file: `/lib/systemd/system/listing.service`
  - Lets view listing service configuration data in Consul:
  ```
  consul kv get -recurse listing/config
  ```
  - Envconsul reads these values and launches the application as a subprocess with these environment variables. The listing service reads these environment variables from [db.js](../../application/listing-service/config/db.js). Note that the environment variables will not show up if you use the `env` command in your SSH session since they are only set for the subprocess.
  - The configuration for envconsul can be seen here: `cat /opt/listing-service/listing_envconsul.hcl`. Lets go over a few parameters in this file:
    - `command = "/usr/bin/node /opt/listing-service/server.js"` tells envconsul how to start the application.
    - The `secret` stanza tells envconsul to read the secret path `mongo/creds/catalog` from Vault. These are set as environment variables: `username` and `password`.
    - The `prefix` stanza tells envconsul to read all key value pairs on the path `listing/config` from Consul's distributed key / value store. These are set as environment variables: `DB_URL`, `DB_PORT`, `DB_NAME` and `DB_COLLECTION`.
  - Lets modify the version string to `1.5` and check the metadata endpoint.
```
consul kv put listing/config/version 1.5
curl listing.service.consul:8000/metadata
```
  You will see version 1.5 returned by the application. Upon updating the version string, envconsul restarted the listing service immediately with updated environment variables.

Switch to the web browser and refresh, the version strings should both say `'version': 1.5` now.

Both envconsul and Consul Template established a watch against Consul at the specified prefix and immediately took action upon an update. This approach allows for fast convergence time to distribute updates at scale.  

Please note that envconsul and Consul Template are not required for service configuration using Consul. While using these tools help with application integration, services can use Consul's REST API to read configuration information directly.

### Dynamic Credentials

This demo uses Vault's [AWS EC2 Authentication method](https://www.vaultproject.io/docs/auth/aws.html#ec2-auth-method) with the [Mongo DB Database Secrets Engine](https://www.vaultproject.io/docs/secrets/databases/mongodb.html#mongodb-database-secrets-engine).
- On your terminal, exit out of the Listing SSH session and issue: `terraform output vault_servers`
- `ssh -i <your_pem_file> ubuntu@<first_dns_returned>`

For this demo, the environment variables `VAULT_ADDR` and `VAULT_TOKEN` have setup already.
- Issue the following commands to view Vault server status. We have a single server install for this demo.
```
vault status
```
- Display the token that was setup; you will see `path auth/token/root` which indicates this is the root token. Note: the root token should be secured per [Vault Production hardening steps](https://learn.hashicorp.com/vault/operations/production-hardening).
```
vault token lookup
```
- Display Vault's Authentication methods, the AWS authentication method is mounted under default `aws` path:
```
vault auth list
```
- Display Vault's Secret engines, Mongo DB Database Secret Engine is mounted under default `mongo` path:
```
vault secrets list
```
- Vault UI (Optional: If you have setup the Terraform variable `security_group_ingress` in your terraform.auto.tfvars, you can view these in the Vault UI. To construct the URL for Vault UI you can issue the command: `echo "http://$(terraform output vault_servers):8200/ui"`. Use the root token from above to authenticate into the UI.

Now lets review how each service renews credentials:

#### Dynamic Credentials for Listing Service with Envconsul
- The listing service uses the Environment Variables `username` and `password` to read Mongo DB credentials. These variables are passed to the listing service by envconsul:
  - Envconsul interacts with Vault using a token that was supplied during bootstrap process.
  - (Optional) View the [init\_listing.tpl](init\_listing.tpl) see this process. You will see the `VAULT_TOKEN` environment variable being set in the systemd unit file: `/lib/systemd/system/listing.service`.
  - Using the supplied token, envconsul reads the MongoDB credential from the path: `mongo/creds/catalog`.

- Let's obtain a new set of credentials using the Vault CLI:
```
vault read mongo/creds/catalog
```
Note that the TTL is only 2 mins which means Vault will auto revoke these credentials after that time.

- Lets go ahead and revoke all leases for mongo:
```
curl \
--header "X-Vault-Token: ${VAULT_TOKEN}" \
--request PUT \
${VAULT_ADDR}/v1/sys/leases/revoke-force/mongo/creds
```
Now refresh the web browser and the Listing service should stop working. Envconsul will restart this application upon the next lease expiry time which is under 120s. At that time it will obtain new credentials and resume working.

**But why is Product service still working??**

#### Dynamic Credentials for Product Service with Vault API
- From a new terminal session, please issue: `terraform output product_api_servers`
- `ssh -i <your_pem_file> ubuntu@<first_dns_returned>`
- The product service uses [Vault hvac Python SDK](https://github.com/hvac/hvac) to authenticate with the Vault server. It obtains a Vault token, then reads the MongoDB credential from the path: `mongo/creds/catalog`.
- You can view the code to do this: `cat /opt/product-service/vaultawsec2.py`. The relevant authentication flow is: `get_mongo_creds() --> get_vault_client --> auth_ec2`.
- View the main code for product service: `cat /opt/product-service/product.py` and inspect the function `get_products_from_db()`. You will notice a retry logic built-in where if authentication fails (e.g. expired credentials), it will try to obtain a new credential:
```
except Exception as e:
       tprint(str(e))
       tprint("Renewing credentials and retrying once -->")
...
       db_client = connect_to_db()
```
- Now search for this string in the syslog: `grep "Renewing credentials and retrying once" /var/log/syslog` and you will one or more instances of this retry. By invokling `/sys/leases/revoke-force/mongo/creds`, and every least TTL duration (120 seconds), Vault revokes Mongo credentials and upon the next health check the application obtains a new Mongo credential.

- For demo purposes the product service logs credentials as a debug log, this is not recommended for production application. You can view these by searching for it in the syslog: `grep "Vault response from AWS EC2 Auth" /var/log/syslog`

We have now seen 2 patterns to for applications to consume Vault secrets: using a tool such as envconsul and direct application integration.
