resource "aws_instance" "wordpress" {
  ami = data.aws_ami.ami-public.id
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.public-ssh.id, aws_security_group.public-web.id]
  subnet_id = element(aws_subnet.public.*.id, 0)
  tags = {
    Name = "wordpress-0-instance"
  }

  provisioner "remote-exec" {
    connection {
      host = self.public_ip
      user = "root"
      password = "DevOps321"
    }

    inline = [
      "sudo yum install git -y ",
      "sudo amazon-linux-extras install ansible2 -y",
      "echo localhost >/tmp/hosts",
      "sudo ansible-pull -i /tmp/hosts -U  https://github.com/bhiravabhatla/aws-compute-tutorials.git ALB/ansible/wordpress.yml --skip-tags mysql"
    ]
  }
}

