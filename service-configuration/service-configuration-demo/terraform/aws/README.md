# Running the Demo

## Overview

This terraform code will spin up a simple three-tier web application _without_ Consul Connect. In summary, the three tiers are: a web frontend `web_client`, 2 APIs: `listing` and `product`, and a MongoDB instance. Please view the main [README](../../README.md) for an Architecture overview.

### Steps
- [Pre-requisites](README.md#pre-requisites)
- [Build AMIs using Packer (Optional)](README.md#build-amis-using-packer-optional-)
- [Provisioning](README.md#provisioning)
- [Service Discovery](README.md#service-discovery)
- [Service Configuration](README.md#service-configuration)
- [Secrets Management](README.md#dynamic-credentials)

### Pre-requisites

1. A machine with git and ssh installed
2. The appropriate [Terraform binary](https://www.terraform.io/downloads.html) for your system. This demo was tested using terraform `v0.11.10`.
3. An AWS account with credentials which allow you to deploy infrastructure.
4. An already-existing [Amazon EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html). *NOTE*: if the EC2 Key Pair you specify is not your default ssh key, you will need to use `ssh -i /path/to/private_key` instead of `ssh` in the commands below

### Build AMIs using Packer (optional)
- The packer configuration used to build the machine images is in the `packer` directory. All images are currently public and reside in AWS `us-east-1` region.
- If you want to build the AWS AMIs use the steps below:
  - Edit the AWS Account # appropriately in `packer/*.json` file. More specifically, adjust the `"owners": ["<your-aws-account-#>"]` parameter to reflect your AWS account #.
  - Change to the `packer` directory: `cd packer`.
  - Then issue the command: `make aws`.

### Provisioning

#### Terraform steps
 1. Open a terminal window and please run the commands:
```
export AWS_ACCESS_KEY_ID="<your access key ID>"
export AWS_SECRET_ACCESS_KEY="<your secret key>"
export AWS_DEFAULT_REGION="us-east-1"
```
    Replace `<your access key ID>` with your AWS Access Key ID and `<your secret key>` with your AWS Secret Access Key (see [Access Keys (Access Key ID and Secret Access Key)](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) for more help). *NOTE*: Currently, the Packer-built AMIs are only in `us-east-1`.

2. Please run: `git clone https://github.com/kawsark/thomas_cc_demo.git`
3. `cd thomas_cc_demo/terraform/aws/`
4. `cp terraform.auto.tfvars.example terraform.auto.tfvars`
5. Edit the `terraform.auto.tfvars` file:
  1. Change the `project_name` to something as below:
     - It should be unique to you.
     - It should be lowercase alphaneumeric, and hyphens is ok.
  2. In the `hashi_tags` line change `owner` to be your email address.  
     **Important**: The combination of `project_name` and `owner` must be unique within your AWS organization. They are used to set Consul cluster membership.

  3. Change `ssh_key_name` to the name of an already existing SSH Keypair in AWS.
  4. Optionally, specify your own IP address (`["<your_ip_address>/32"]`)  for the variable `security_group_ingress`. This is only needed if you want to access Vault and/or Consul UI. You can visit [http://whatismyip.akamai.com](http://whatismyip.akamai.com) to find your IP address.

4. Save your changes to the `terraform.auto.tfvars` file
5. Run `terraform init`, when you see: "Terraform has been successfully initialized!":
6. Run `terraform plan`, if everything looks good, run `terraform apply`. Reply `yes` to Terraform confirmation prompt.

This will take a couple minutes to run. Once the command prompt returns, wait a couple minutes and the demo will be ready.

#### Access the application

 1. `terraform output webclient-lb`
 2. Point a web browser at the value returned

### Service Discovery

 1. `terraform output webclient_servers`
 2. `ssh -i <your_pem_file> ubuntu@<first_dns_returned>`
    1. When asked `Are you sure you want to continue connecting (yes/no)?` answer `yes` and hit enter
 3. `cat /lib/systemd/system/web_client.service`
    1. The line `Environment=LISTING_URI=http://listing.service.consul:8000` tells `web_client` how to talk to the `listing` service
    2. The line `Environment=PRODUCT_URI=http://product.service.consul:5000` tells `web_client` how to talk to the `product` service
    3. Note how both are using Consul for service discovery, the services are finding each other dynamically.

 4. `cat /etc/consul/web_client.hcl` shows the `web_client` Consul service definition file with some health checks.

### Service Configuration

1. On the web browser "Product metadata" and "Listing metadata" sections, note the version string for both Product and Listing service. It should say `'version': 1.0`.
2. Switch to the terminal where you had a SSH session established with the web_client. View the version strings stored in Consul distributed KV store:
```
consul kv get product/config/version
consul kv get listing/config/version
```
Try adding `-detailed` to see additional kv metadata: `consul kv get -detailed product/config/version`

3. Consul UI (optional): If you have setup the Terraform variable `security_group_ingress` in your terraform.auto.tfvars, you can view these in the Consul UI. To construct the URL for Consul UI you can issue the command `terraform output consul_servers` and use any DNS name with port 8500: `"http://<consul_server>:8500/ui"`

#### Service Configuration for Product service
  - On your terminal, exit out of the web_client SSH session and issue: `terraform output product_api_servers`
  - `ssh -i <your_pem_file> ubuntu@<first_dns_returned>`
  - View product service configuration using the `-recurse` option to view all key / value pairs:
  ```
  consul kv get -recurse product/config
  ```
  - Consul-template reads these values and renders an application configuration file: `/opt/product-service/config.yml`. Display the contents of this file: `cat /opt/product-service/config.yml`.

  - Lets modify the version string: `consul kv put product/config/version 1.5`. Consul-template will restart the product service with the values. You can see the update take effect immediately:
  ```
  cat /opt/product-service/config.yml
  curl -s product.service.consul:5000/product/metadata
  ```
  - The configuration for consul-template can be seen here: `cat /opt/product-service/product_consul_template.hcl`.
  - The following line tells consul-template where to find the input template:
  ```
  source = "/opt/product-service/config.ctpl"
  ```
  - If you display the above file it will show where consul-template pulls the configuration from: `cat /opt/product-service/config.ctpl`. You will notice a set of `keyOrDefault` entries. This tells Consul-template to look for the specified key in Consul's distributed key/value store, then render the corresponding value. If the specified key is not found, then Consul-template will use the default value.

#### Service Configuration for Listing service
  - On your terminal, exit out of the Listing SSH session and issue: `terraform output listing_api_servers`
  - `ssh -i <your_pem_file> ubuntu@<first_dns_returned>`
  - View product service configuration using the `-recurse` option to view all key / value pairs:
  ```
  consul kv get -recurse listing/config
  ```
  - Envconsul reads these values and launches the application as a subprocess with these Environment variables.
  - Lets modify the version string: `consul kv put listing/config/version 1.5`. Envconsul will restart the listing service with updated values.
  - You can see the update take effect using this command: `curl listing.service.consul:8000/metadata`
  - The configuration for Envconsul can be seen here: `cat /opt/listing-service/listing_envconsul.hcl`. Lets go over a few parameters in this file:
    - `command = "/usr/bin/node /opt/listing-service/server.js"` tells Envconsul how to start the application.
    - The `secret` stanza tells Envconsul to read the secret path `mongo/creds/catalog` from Vault. These are set as environment variables: `username` and `password`.
    - The `prefix` stanza tells Envconsul to read all key value pairs on the path `listing/config` from Consul's distributed key / value store. These are set as environment variables: `DB_URL`, `DB_PORT`, `DB_NAME` and `DB_COLLECTION`.

3. Switch to the web browser and refresh, the version strings should both say `'version': 1.5` now.

Note: Envconsul and Consul-template are not required for distributed service configuration. While using these tools help with application integration, services can use Consul's REST API to read application configuration information.

### Dynamic Credentials

This demo uses Vault's [AWS EC2 Authentication method](https://www.vaultproject.io/docs/auth/aws.html#ec2-auth-method) with the [Mongo DB Database Secrets Engine](https://www.vaultproject.io/docs/secrets/databases/mongodb.html#mongodb-database-secrets-engine).
- On your terminal, exit out of the Listing SSH session and issue: `terraform output vault_servers`
- `ssh -i <your_pem_file> ubuntu@<first_dns_returned>`

For this demo, the environment variables `VAULT_ADDR` and `VAULT_TOKEN` have setup already.
- Issue the following commands to view Vault server status. We have a single server install for this demo.
```
vault status
```
- Display the token that was setup; you will see `path auth/token/root` which indicates this is the root token.
```
vault token lookup
```
  - Note: The root token should be secured per [Vault Production hardening steps](https://learn.hashicorp.com/vault/operations/production-hardening).

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

#### Dynamic Credentials for Listing service
- The listing service uses the Environment Variable `password` to read Mongo DB credentials. Envconsul interacts with Vault using a token that was supplied during bootstrap process.
  - _(Optional) View the [init\_listing.tpl](init\_listing.tpl) see this process._

- Envconsul obtains a Vault token, then reads the MongoDB credential from the path: `mongo/creds/catalog`.

- Similarly, we can obtain a new set of credentials from the CLI:
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
Now refresh the web browser and the Listing service should stop working. Envconsul will restart this application upon next lease expiry time which is under 120s. At that time it will obtain new credentials and resume working.

**But why is Product service still working??**

#### Dynamic Credentials for Product service
- SSH into the product service and issue: `terraform output product_api_servers`
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

We have now seen 2 patterns to for applications to consume Vault secrets: using a tool such as Envconsul and direct application integration.
