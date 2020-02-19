data "aws_ami" "ami-public" {
  most_recent      = true
  owners           = [var.AMI_ACCOUNT]
  name_regex       = "^Centos-7*"
}