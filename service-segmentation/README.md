### Consul Service Segmentation guides

Consul from Hashicorp is a comprehensive Service Mesh solution that solves for 3 areas of distributed service network layer: Service Discovery, Service Segmentation and Service Configuration.

The guides here are related to the Service Segmentation use-case using using [Consul Connect](https://www.consul.io/docs/connect/index.html).

- [Consul Connect Guide: python-to-redis](python-to-redis/): A simple guide for using Consul Connect to secure communication between a Redis service and python client. This guide includes both Vagrant and Terraform steps, and uses the built-in sidecar proxy.
- [Consul Connect with Nomad Demo](https://github.com/hashicorp/nomad-guides/tree/master/application-deployment/consul-connect-with-nomad): A simple guide for using Nomad to launch two Docker containers with Consul Connect proxies that can be configured to allow or deny communication between the application and associated database running in the containers. Note that this guide is in the related [nomad-guides](https://github.com/hashicorp/nomad-guides) repository.
