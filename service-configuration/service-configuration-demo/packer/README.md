# Packer steps

All images are currently public and reside in AWS `us-east-1` region. The images were built using packer version `1.3.1`.

If you want to build your own AWS AMIs, please use the steps below:
  - Edit the AWS Account # appropriately in `packer/*.json` files. More specifically, adjust the `"owners": ["<your-aws-account-#>"]` parameter to reflect your AWS account #.
  - Change to the `packer` directory: `cd packer`.
  - Setup your AWS credentials:
```
export AWS_ACCESS_KEY=<your_aws_access_key_id>
export AWS_SECRET_KEY=<your_aws_secret_access_key>
```
  - Copy the [packer.example.sh](packer.example.sh) file and adjust `AWS_REGION`, `DC_NAME` and anything else you want to update.
```
cp packer.example.sh packer.sh
# Update AWS_REGION, DC_NAME and anything else you want to change
```
  - Update permission and run the script
```
chmod +x packer.sh
./packer.sh
```
