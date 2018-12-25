resource "aws_iam_role" "vault_ec2_role" {
  name               = "vault-role"
  description = "Vault Server IAM Role"

  assume_role_policy = <<EOF
{ 
  "Version": "2012-10-17",
  "Statement": [
    { 
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "vault_ec2_profile" {                             
	 name  = "vault-profile"                         
	 role = "${aws_iam_role.vault_ec2_role.name}"
}

resource "aws_iam_policy" "vault_policy" {
  name        = "vault-policy"
  description = "policy for Vault server on AWS"
  policy      = "${file("vaultpolicy.json")}"
}

resource "aws_iam_policy_attachment" "vault-attach" {
  name       = "vault-attachment"
  roles      = ["${aws_iam_role.vault_ec2_role.name}"]
  policy_arn = "${aws_iam_policy.vault_policy.arn}"
}