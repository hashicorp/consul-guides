data "aws_ami" "vault" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-vault-server-*"]
    }
}

data "aws_ami" "consul" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-consul-server-*"]
    }
}

data "aws_ami" "mongo-noconnect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-mongodb-noconnect-*"]
    }
}

data "aws_ami" "mongo-connect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-mongodb-connect-*"]
    }
}

data "aws_ami" "product-api-noconnect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-product-noconnect-*"]
    }
}

data "aws_ami" "product-api-noconnect-consul-template" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-product-consul-template-noconnect-*"]
    }
}

data "aws_ami" "product-api-connect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-product-connect-*"]
    }
}

data "aws_ami" "listing-api-connect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-listing-server-connect-*"]
    }
}

data "aws_ami" "listing-api-noconnect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-listing-server-noconnect-*"]
    }
}

data "aws_ami" "listing-api-noconnect-envconsul" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-listing-envconsul-noconnect-*"]
    }
}

data "aws_ami" "webclient-connect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-webclient-connect-*"]
    }
}

data "aws_ami" "webclient-noconnect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-webclient-noconnect-*"]
    }
}
