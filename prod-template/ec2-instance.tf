#create Edge-server
resource "aws_instance" "edge-server" {
  ami = "${var.ami_id}"
  instance_type = "${var.edge_instance_type}"
  key_name = "${var.customer}-key"
  security_groups = ["${aws_security_group.edge_SG.id}"]
  #lifecycle {
#    prevent_destroy = true
#  }

tags = {
  Name = "Edge ${var.customer}"
}
root_block_device {
 volume_size = 20
}
subnet_id = "${aws_subnet.live_subnet.id}"


  connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = aws_instance.edge-server.public_ip
      private_key = file("~/terraform/thebodyshop/ssh-keys/${var.customer}-key.pem")
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
    command = "cd /home/workstation/chef/ && knife bootstrap ${aws_instance.edge-server.public_ip} --ssh-user ec2-user -N edge.thebodyshop.com --sudo"
  }
  provisioner "local-exec" {
    command = "cd /home/workstation/chef/ && sudo knife node run_list add edge.thebodyshop.com yum-epel,yum-webtatic,yum_varnish6,yum-luroconnect,min_sys_pkgs,nginx_install,erlang,install_rabitmq,varnish6"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chef-client",
    ]
 }
}




resource "aws_instance" "db-server" {
  ami = "${var.ami_id}"
  instance_type = "${var.db_instance_type}"
  key_name = "${var.customer}-key"
  security_groups = ["${aws_security_group.app_SG.id}"]
#  lifecycle {
#    prevent_destroy = true
#  }

tags = {
  Name = "DB ${var.customer}"
}
root_block_device {
 volume_size = 20
}
subnet_id = "${aws_subnet.live_subnet.id}"


  connection {
      type        = "ssh"
      user        = "ec2-user"
  #    host        = aws_instance.staging-server.public_ip
       host 	   = "${self.public_ip}"   
       private_key = file("~/terraform/thebodyshop/ssh-keys/${var.customer}-key.pem")
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
    command = "cd /home/workstation/chef/ && knife bootstrap ${self.public_ip} --ssh-user ec2-user -N db.thebodyshop.com --sudo"
  }
  provisioner "local-exec" {
    command = "cd /home/workstation/chef/ && sudo knife node run_list add db.thebodyshop.com yum-epel,yum-webtatic,yum-luroconnect,min_sys_pkgs,install_mysql_5.7,install_redis"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chef-client",
    ]
 }
}


resource "aws_instance" "app-server" {
  ami = "${var.ami_id}"
  instance_type = "${var.app_instance_type}"
  key_name = "${var.customer}-key"
  security_groups = ["${aws_security_group.app_SG.id}"]

tags = {
  Name = "APP ${var.customer}"
}
root_block_device {
 volume_size = 10
}
subnet_id = "${aws_subnet.live_subnet.id}"

  connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = "${self.public_ip}"
      private_key = file("~/terraform/thebodyshop/ssh-keys/${var.customer}-key.pem")
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
    command = "cd /home/workstation/chef/ && knife bootstrap ${self.public_ip} --ssh-user ec2-user -N app.thebodyshop.com --sudo"
  }
  provisioner "local-exec" {
    command = "cd /home/workstation/chef/ && sudo knife node run_list add app.thebodyshop.com yum-epel,yum-webtatic,yum-luroconnect,min_sys_pkgs,install_php72"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chef-client",
    ]
 }
}




#Attach a pub key to access ec2
resource "aws_key_pair" "ssh-key" {
  key_name   = "${var.customer}-key"
  public_key = "${file("${var.key_pair_path}")}"
}

## Creating EBS volume for Edge
  resource "aws_ebs_volume" "Edge" {
  availability_zone = "${var.availabilityZone}"
  size              = 150
tags = {
  Name = "Edge-Ebs"
}
}

## Creating EBS volume for DB
resource "aws_ebs_volume" "db" {
  availability_zone = "${var.availabilityZone}"
  size              = 100
tags = {
  name = "DB-EBS"
}
}



## Attach Ebs to Edge
resource "aws_volume_attachment" "Edge_att" {
  device_name = "/dev/sdc"
  volume_id   = "${aws_ebs_volume.Edge.id}"
  instance_id = "${aws_instance.edge-server.id}"
}

## Attach Ebs to Database
resource "aws_volume_attachment" "db_att" {
  device_name = "/dev/sdc"
  volume_id   = "${aws_ebs_volume.db.id}"
  instance_id = "${aws_instance.db-server.id}"
}





