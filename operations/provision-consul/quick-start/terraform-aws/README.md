# Provision a Quick Start Consul Cluster in AWS

The goal of this guide is to allows users to easily provision a quick start Consul cluster in just a few commands.

## Reference Material

- [Terraform Getting Started](https://www.terraform.io/intro/getting-started/install.html)
- [Terraform Docs](https://www.terraform.io/docs/index.html)
- [Consul Getting Started](https://www.consul.io/intro/getting-started/install.html)
- [Consul Docs](https://www.consul.io/docs/index.html)

## Estimated Time to Complete

5 minutes.

## Challenge

There are many different ways to provision and configure an easily accessible quick start Consul cluster, making it difficult to get started.

## Solution

Provision a quick start Consul cluster in a private network with a bastion host.

The AWS Quick Start Consul guide leverages the scripts in the [Guides Configuration Repo](https://github.com/hashicorp/guides-configuration) to do runtime configuration for Consul. Although using `curl bash` at runtime is _not_ best practices, this makes it quick and easy to standup a Consul cluster with no external dependencies like pre-built images. This guide will also forgo setting up TLS/encryption on Consul for the sake of simplicity.

## Prerequisites

- [Download Terraform](https://www.terraform.io/downloads.html)

## Steps

We will now provision the quick start Consul cluster.

### Step 1: Initialize

Initialize Terraform - download providers and modules.

#### CLI

[`terraform init` Command](https://www.terraform.io/docs/commands/init.html)

##### Request

```sh
$ terraform init
```

##### Response
```
```

### Step 2: Plan

Run a `terraform plan` to ensure Terraform will provision what you expect.

#### CLI

[`terraform plan` Command](https://www.terraform.io/docs/commands/plan.html)

##### Request

```sh
$ terraform plan
```

##### Response
```
```

### Step 3: Apply

Run a `terraform apply` to provision the HashiStack. One provisioned, view the `zREADME` instructions output from Terraform for next steps.

#### CLI

[`terraform apply` command](https://www.terraform.io/docs/commands/apply.html)

##### Request

```sh
$ terraform apply
```

##### Response
```
```

## Next Steps

Now that you've provisioned and configured a quick start Consul cluster, start walking through the [Consul Guides](https://www.consul.io/docs/guides/index.html).
