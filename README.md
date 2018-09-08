----
-	Website: https://consul.io
-	GitHub repository: [https://github.com/hashicorp/consul-guides](https://github.com/hashicorp/consul-guides)
-	[Gitter](http://gitter.im) [hashicorp-consul](https://gitter.im/hashicorp-consul/Lobby)
-	Announcement list: [Google Groups hashicorp-announce](https://groups.google.com/group/hashicorp-announce)
-	Discussion list: [Google Groups consul-tool](https://groups.google.com/group/consul-tool)
-	Discussion list: [Google Groups](https://groups.google.com/group/vault-tool)


<img src="common/images/Consul_VerticalLogo_FullColor.r1x9c1CS6x.svg" width="15%">

----

# Consul Guides

This repository aims to assist individuals in learning how to install, configure, and administer HashiCorp Consul.

## Disclaimer

This repo is a work in progress. We've decided to open source it while we build as the initial examples may be useful for some. Please bear with us while we work to create meaningful content that will be useful for all.

## Operations Guides

Guides for Consul Operational tasks.

* [Provision a Dev Consul Cluster locally with Vagrant](operations/provision-consul/dev/vagrant-local)
* [Provision a Dev Consul Cluster on AWS with Terraform](operations/provision-consul/dev/terraform-aws)
* [Provision a Quick Start Consul Cluster on AWS with Terraform](operations/provision-consul/quick-start/terraform-aws)
* [Provision a Best Practices Consul Cluster on AWS with Terraform](operations/provision-consul/best-practices/terraform-aws)
* [Automated Upgrades with Consul Enterprise](operations/automated-upgrades)
* [ ] Automated Backups with Consul Enterprise

## Service Discovery Guides

This area contains example use cases for how to use Consul for service discovery.

## Service Configuration Guides

None yet, check back soon or feel free to [contribute](CONTRIBUTING.md)!

## Service Segementation Guides

This area contains examples of securing service-to-service communication using [Consul Connect](https://www.consul.io/docs/connect/index.html).

## Assets

This directory contains graphics and other material for the repository.

## `gitignore.tf` Files

You may notice some [`gitignore.tf`](operations/provision-consul/best-practices/terraform-aws/gitignore.tf) files in certain directories. `.tf` files that contain the word "gitignore" are ignored by git in the [`.gitignore`](./.gitignore) file.

If you have local Terraform configuration that you want ignored (like Terraform backend configuration), create a new file in the directory (separate from `gitignore.tf`) that contains the word "gitignore" (e.g. `backend.gitignore.tf`) and it won't be picked up as a change.

## Contributing

We welcome contributions and feedback!  For guide submissions, please see [the contributions guide](CONTRIBUTING.md)
