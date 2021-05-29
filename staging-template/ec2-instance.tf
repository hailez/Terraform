#create stagingserver


resource "aws_instance" "staging-server" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = "${var.customer}-key"
  security_groups = [aws_security_group.staging_SG.id]
  subnet_id = aws_subnet.staging_subnet.id

tags = {
  Name = "stagingm24.paragonfootwear.com"
}
root_block_device { 
 volume_size = 10
}


  connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = aws_instance.staging-server.public_ip
      private_key = file("~/terraform/stagingm24-paragonfootwear/ssh-keys/${var.customer}-key.pem")
    }

  provisioner "file" {
    source      = "/home/workstation/.ssh/id_rsa.pub"
    destination = ".ssh/chef_rsa.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "cat .ssh/chef_rsa.pub >> .ssh/authorized_keys",
    ]
  }

  provisioner "local-exec" {
    command = "cd /home/workstation/chef/ && knife bootstrap ${aws_instance.staging-server.public_ip} --ssh-user ec2-user -N stagingm24.paragonfootwear.co --sudo"
  }
  provisioner "local-exec" {
    command = "cd /home/workstation/chef/ && sudo knife node run_list add stagingm24.paragonfootwear.co yum-epel,yum-webtatic,yum_varnish6,yum-luroconnect,min_sys_pkgs,nginx_install,erlang,install_rabitmq,varnish6,yum-elastic7,install_mysql_8,install_java,install_redis"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chef-client",
    ]
 }
}





resource "aws_key_pair" "ssh-key" {
  key_name   = "${var.customer}-key"
  public_key = file("/home/workstation/terraform/stagingm24-paragonfootwear/ssh-keys/id_rsa.pub")
}


## Creating EBS volume for staging
  resource "aws_ebs_volume" "Staging" {
  availability_zone = var.availabilityZone
  size              = 100

tags = {
  Name = "stagingM24-Ebs"
}
}

## Attach Ebs to Staging
resource "aws_volume_attachment" "staging_att" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.Staging.id
  instance_id = aws_instance.staging-server.id
}
