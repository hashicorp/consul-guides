## Consul Connect guide for Python to Redis
This guide consists of a python client microservice called `clientms`, connecting to an upstream `redis` service.
- Each service is hosted as a Docker container.
- The services will communicate with each other via the Consul Connect managed sidecar proxy.

There are 2 different ways to setup this guide depending on the desired level of complexity. Please view  `README.md` file in the appropriate subdirectory to proceed with this guide:

1. [vagrant-local](vagrant-local/): Guide with each service running on separate **Vagrant VMs** on a local machine.

2. [terraform-aws](terraform-aws/): Guide with each service running on separate **AWS EC2 instances**.
