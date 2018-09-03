export CONSUL_DEMO_VERSION=1.2.2 

#Install Consul and dependencies
echo "Installing dependencies ..."
sudo apt-get update
sudo apt-get install -y git unzip curl jq dnsutils
echo "Fetching Consul version ${CONSUL_DEMO_VERSION} ..."
cd /tmp/
curl -s https://releases.hashicorp.com/consul/${CONSUL_DEMO_VERSION}/consul_${CONSUL_DEMO_VERSION}_linux_amd64.zip -o consul.zip
echo "Installing Consul version ${CONSUL_DEMO_VERSION} ..."
unzip consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul
sudo mkdir /etc/consul.d
sudo chmod a+w /etc/consul.d

#Install Docker
apt-get update -y
apt-get upgrade -y
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

# Build the Docker image:
docker build -t python-clientms /tmp/setup/clientms/  

# Install and start Consul service
cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target
[Service]
Restart=always
RestartSec=15s
User=ubuntu
Group=ubuntu
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
[Install]
WantedBy=multi-user.target
EOF

# Download repo and copy files:
cp /tmp/setup/consul/consul_n1.json /etc/consul.d/consul.json
cp /tmp/setup/consul/clientms.json /etc/consul.d/clientms.json
systemctl enable consul.service
systemctl start consul.service

# Start the application
docker run --name clientms --net=host -d -e REDIS_HOST=localhost -e REDIS_PORT=6400 python-clientms 
