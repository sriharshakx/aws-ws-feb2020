resource "aws_instance" "wordpress" {
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.public-ssh.id, aws_security_group.public-web.id]
  key_name = var.key_name
  subnet_id = element(aws_subnet.public.*.id, 0)
  tags = {
    Name = "wordpress-0-instance"
  }

  provisioner "remote-exec" {
    connection {
      host = self.public_ip
      user = "ec2-user"
      private_key = file("/root/devops.pem")
    }

    inline = [
      "sudo yum install git -y ",
      "sudo amazon-linux-extras install ansible2 -y",
      "cd /home/ec2-user && git clone https://github.com/bhiravabhatla/aws-compute-tutorials.git",
      "cd /home/ec2-user/aws-compute-tutorials/ALB/ansible && sudo ansible-playbook -i local wordpress.yml --skip-tags mysql"
    ]
  }
}

