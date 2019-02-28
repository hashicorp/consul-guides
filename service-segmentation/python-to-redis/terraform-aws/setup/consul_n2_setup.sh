export CONSUL_DEMO_VERSION=1.4.2

#Install Consul and dependencies
echo "Installing dependencies ..."
apt-get update -y
apt-get install -y git unzip curl jq dnsutils dnsmasq
echo "Fetching Consul version ${CONSUL_DEMO_VERSION} ..."
cd /tmp/
curl -s https://releases.hashicorp.com/consul/${CONSUL_DEMO_VERSION}/consul_${CONSUL_DEMO_VERSION}_linux_amd64.zip -o consul.zip
echo "Installing Consul version ${CONSUL_DEMO_VERSION} ..."
unzip consul.zip
chmod +x consul
mv consul /usr/bin/consul
mkdir /etc/consul.d
chmod a+w /etc/consul.d

#Install and start Docker
apt-get update -y
apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual -y
apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y
apt-get install docker-ce -y
groupadd docker
usermod -aG docker ubuntu
systemctl enable docker.service
systemctl start docker.service
sleep 5

#Start Redis:
docker run --name=redis -d -p 6379:6379 redis:latest

#Download repo and copy files:
cp /tmp/setup/consul/consul.service /etc/systemd/system/consul.service
cp /tmp/setup/consul/consul_n2.json /etc/consul.d/consul.json
cp /tmp/setup/consul/redis.json /etc/consul.d/redis.json
cp /tmp/setup/consul/redis-sidecar.service /etc/systemd/system/sidecar\
.service

systemctl enable consul.service
systemctl start consul.service
sleep 10

echo "Setup DNS masq"
cat <<EOF > /etc/dnsmasq.d/consul.dnsmasq
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EOF
cp /etc/resolv.conf /etc/resolv.conf.backup
echo "nameserver 127.0.0.1" | tee /etc/resolv.conf
cat /etc/resolv.conf.backup | tee --append /etc/resolv.conf
systemctl restart dnsmasq

# See: https://github.com/hashicorp/consul/issues/4455
curl -s localhost:8500/v1/agent/connect/ca/roots
systemctl enable sidecar.service
systemctl start sidecar.service
