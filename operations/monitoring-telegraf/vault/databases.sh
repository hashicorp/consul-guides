#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
apt-get update && apt-get -y install mongodb-org
install -c -m 0644 /vagrant/vault/mongod.conf /etc

systemctl enable mongod
systemctl restart mongod

debconf-set-selections <<< 'mysql-server mysql-server/root_password password abc123'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password abc123'
apt-get -y install mysql-server
install -c -m 0644 /vagrant/vault/mysqld.cnf /etc/mysql/mysql.conf.d

systemctl enable mysql
systemctl restart mysql

mysql -u root -pabc123 -e "create user root@'%' identified by 'abc123'"
mysql -u root -pabc123 -e "grant all privileges on *.* to root@'%' with grant option"
mysql -u root -pabc123 -e "grant proxy on '@' to root@'%'"
mysql -u root -pabc123 -e "flush privileges"
