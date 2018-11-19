# Terraform configuration for Minimum Viable Deployment (CC-DEMO)

provider "aws" {
 # AWS provider configured via environment variables: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
  region = "${var.aws_region}"
}

# VPC
resource "aws_vpc" "cc-demo-vpc" {
  cidr_block           = "172.16.20.0/24"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags {
    Name = "cc-demo-vpc"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

# Public Subnet
resource "aws_subnet" "cc-demo-public-1" {
  vpc_id                  = "${aws_vpc.cc-demo-vpc.id}"
  cidr_block              = "172.16.20.0/25"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}a"

  tags {
    Name = "cc-demo-public-1"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

# Internet GW
resource "aws_internet_gateway" "cc-demo-gw" {
  vpc_id = "${aws_vpc.cc-demo-vpc.id}"

  tags {
    Name = "cc-demo-gw"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

#Public route table with IGW
resource "aws_route_table" "cc-demo-public" {
  vpc_id = "${aws_vpc.cc-demo-vpc.id}"

tags {
    Name = "cc-demo-public-1"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

#Public route
resource "aws_route" "cc-demo-public-route" {
  route_table_id = "${aws_route_table.cc-demo-public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.cc-demo-gw.id}"
}

# route associations public
resource "aws_route_table_association" "cc-demo-public-1-a" {
  subnet_id      = "${aws_subnet.cc-demo-public-1.id}"
  route_table_id = "${aws_route_table.cc-demo-public.id}"
}

resource "aws_security_group" "cc-demo-sg" {
  vpc_id      = "${aws_vpc.cc-demo-vpc.id}"
  description = "security group that allows ssh and all egress traffic"

  tags {
    Name = "cc-demo-sg"
    App  = "${var.App}"
    Env  = "${var.environment}"
  }
}

resource "aws_security_group_rule" "egress_allow_all" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.cc-demo-sg.id}"
}

resource "aws_security_group_rule" "ingress_allow_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.cc-demo-sg.id}"
}

resource "aws_security_group_rule" "ingress_allow_consul_interface" {
  type            = "ingress"
  from_port       = 8500
  to_port         = 8600
  protocol        = "all"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.cc-demo-sg.id}"
}

# Obtain AMI ID
data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"] # Canonical
}

# Create a new RSA key pair for ssh
resource "tls_private_key" "ssh_key_pair" {
  algorithm   = "RSA"
  rsa_bits    = "4096"
}

# Create a AWS key pair
resource "aws_key_pair" "cc-demokeypair" {
  key_name   = "cc-demokeypair"
  public_key = "${tls_private_key.ssh_key_pair.public_key_openssh}"
}

# consul_n1
resource "aws_instance" "consul-n1-clientms" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_size}"
  availability_zone = "${var.aws_region}a"
  key_name = "${aws_key_pair.cc-demokeypair.key_name}"
  vpc_security_group_ids = ["${aws_security_group.cc-demo-sg.id}"]
  subnet_id = "${aws_subnet.cc-demo-public-1.id}"
  private_ip = "172.16.20.10"

  tags {
    Name = "consul-n1-clientms"
    App = "clientms"
    owner = "${var.owner}"
    TTL = "${var.ttl}"
  }

  # File provisioner - Copies the setup directory to /tmp
  provisioner "file" {
    source      = "./setup"
    destination = "/tmp"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = "${self.public_dns}"
      private_key = "${tls_private_key.ssh_key_pair.private_key_pem}"
    }
  }

  # Remote exec provisioner
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup/consul_n1_setup.sh",
      "cd /tmp/setup && sudo ./consul_n1_setup.sh",
    ]

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = "${self.public_dns}"
      private_key = "${tls_private_key.ssh_key_pair.private_key_pem}"
    }
  }
}

# consul_n2
resource "aws_instance" "consul-n2-redis-server" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_size}"
  availability_zone = "${var.aws_region}a"
  key_name = "${aws_key_pair.cc-demokeypair.key_name}"
  vpc_security_group_ids = ["${aws_security_group.cc-demo-sg.id}"]
  subnet_id = "${aws_subnet.cc-demo-public-1.id}"
  private_ip = "172.16.20.11"

  tags {
    Name = "consul-n2-redis-server"
    App = "Redis"
    owner = "${var.owner}"
    TTL = "${var.ttl}"
  }

  # File provisioner - Copies the setup directory to /tmp
  provisioner "file" {
    source      = "./setup"
    destination = "/tmp"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = "${self.public_dns}"
      private_key = "${tls_private_key.ssh_key_pair.private_key_pem}"
    }
  }

  # Remote exec provisioner
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup/consul_n2_setup.sh",
      "cd /tmp/setup && sudo ./consul_n2_setup.sh",
    ]

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = "${self.public_dns}"
      private_key = "${tls_private_key.ssh_key_pair.private_key_pem}"
    }
  }
}
