# Provision a Development Consul Cluster in Vagrant

The goal of this guide is to allows users to easily provision a development Consul cluster in just a few commands.

## Reference Material

- [Vagrant Getting Started](https://www.vagrantup.com/intro/getting-started/index.html)
- [Vagrant Docs](https://www.vagrantup.com/docs/index.html)
- [Consul Getting Started](https://www.consul.io/intro/getting-started/install.html)
- [Consul Docs](https://www.consul.io/docs/index.html)

## Estimated Time to Complete

5 minutes.

## Challenge

There are many different ways to provision and configure an easily accessible development Consul cluster, making it difficult to get started.

## Solution

Provision a development Consul cluster in Vagrant.

The Vagrant Development Consul guide is for **educational purposes only**. It's designed to allow you to quickly standup a single instance with Consul running in `-dev` mode. The single node is provisioned into a local VM, allowing for easy access to the instance. Because Consul is running in `-dev` mode, all data is in-memory and not persisted to disk. If any agent fails or the node restarts, all data will be lost. This is only mean for local use.

## Prerequisites

- [Download Vagrant](https://www.vagrantup.com/downloads.html)
- [Download Virtualbox](https://www.virtualbox.org/wiki/Downloads)

## Steps

We will now provision the development Consul cluster in Vagrant.

### Step 1: Start Vagrant

Run `vagrant up` to start the VM and configure Consul. That's it! Once provisioned, view the Vagrant ouput for next steps.

#### CLI

[`vagrant up` Command](https://www.vagrantup.com/docs/cli/up.html)

##### Request

```sh
$ vagrant up
```

##### Response
```
```

## Next Steps

Now that you've provisioned and configured a development Consul cluster, start walking through the [Consul Guides](https://www.consul.io/docs/guides/index.html).
