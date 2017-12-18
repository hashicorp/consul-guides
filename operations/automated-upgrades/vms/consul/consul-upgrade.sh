
#doitlive speed: 3
#doitlive theme: nicolauj
#doitlive prompt: $ 
#doitlive commentecho: true
#doitlive unset: CONSUL_HTTP_ADDR

vagrant up /consul/
for i in consula0 consula1 consula2 consulb0 consulb1 consulb2; do vagrant ssh -c "sudo rm -rf /var/hashicorp/consul; sudo service hashicorp-consul-enterprise stop" $i; done
for i in consula0 consula1 consula2 ; do vagrant provision $i --provision-with configure,validate ; done
clear

#
# Alright, let's talk about Consul Enterprise Automated Upgrades:
#
# https://www.consul.io/docs/enterprise/upgrades/index.html
#
# Automated Upgrades can be coodinated by version of the Consul Enterprise
# binary running on the set of Consul Servers or, as in this example,
# via an arbitrary Consul node metadata tag. The metadata tag is a k/v pair.
# A little later we'll specify the key to be used to coordinate the upgrades.
# The value in the k/v pair is explained below.
#
# Here's some documentation about Consul node metadata tags:
#
# https://www.consul.io/docs/agent/options.html#_node_meta
#
# In order to save time, I've already provisioned two sets of Consul Server
# nodes:
#
#   * consula* - with node metadata indicating version 0.0.1 and already
#      participatingn in the cluster.
# 
#   * consulb* - with node metadata indicating version 1.0.0 and **not**
#      currently participating in the cluster.
#				     
vagrant status

#
# Looking at the set of Consul Server peers, we can see the three provisioned
# and in-cluster nodes...
#
http http://localhost:8500/v1/status/peers

#
# And who is our Consul cluster leader...
#
http http://localhost:8500/v1/status/leader

#
# Now let's look at the node metadata associated with our running nodes...
# 
# For our demo, we'll use the 'cluster_version' tag with SemVer for
# coordinating automatic upgrades...
#
#doitlive env: CONSUL_HTTP_ADDR=http://localhost:8500
export CONSUL_HTTP_ADDR=http://localhost:8500
consul catalog nodes -detailed | em cluster_version
consul operator raft list-peers | em true

#
# And let's verify that we do NOT have a previously configured automatic
# upgrade configuration...
#
consul operator autopilot get-config | grep upgrade-version-tag

#
# Note that when using node metadata tags for coordinating automatic upgrades,
# SemVer of the v in the tag k/v is required.
#
# In this case, we are upgrading the set of voting Consul Servers from version
# '0.0.1' to version '1.0.0'.
#
consul operator autopilot set-config -upgrade-version-tag=cluster_version
consul operator autopilot get-config | grep -i upgrade

#
# Let's start up our remaining Consul Servers...
#
# Watch closely and you will see that the new nodes are **not** allowed to be
# voting members of the cluster due to the set of upgrade-version-tag above.
#
# Once there are enough 1.0.0 nodes in the cluster to replace all of the
# 0.0.1 nodes, the autoamted upgrade will commence. Voter status will transition
# on node at a time thus ensuring quorum and handling any leader elections
# which may be necessary during the upgrade process. 
# 
# You can track the progress of the upgrade by watching the browser windows
# and the "watch" windows running above.b
#
# The Vagrant port mappings are such that:
#
#   * tcp/localhost:8500 points to consula0
#   * tcp/localhost:8501 points to consulb0
#
for i in consulb0 consulb1 consulb2 ; do vagrant provision $i --provision-with configure,validate ; done

#
# Keep an eye on the "watch" windows above...
#
# You should be seeing the voter statuses changing as well as any required
# leader elections...
#
sleep 20
consul catalog nodes -detailed | em cluster_version
consul operator raft list-peers | em true

#
# Let's shutdown all of the Consul Server nodes with node metadata of '0.0.1'.
# Note that Consul Enterprise autopilot will remove the old/shutdown nodes
# automatically after 72 hours but here we will do the right thing and
# have the nodes 'leave' before they are halted.
#
for i in consula0 consula1 consula2; do vagrant ssh -c 'sudo consul leave' $i; done
vagrant halt /consula/

#
# And finally let's validate the state of the Consul Server in terms of voting
# members...
#
#doitlive env: CONSUL_HTTP_ADDR=http://localhost:8501
export CONSUL_HTTP_ADDR=http://localhost:8501
consul catalog nodes -detailed | em cluster_version
consul operator raft list-peers | em true
