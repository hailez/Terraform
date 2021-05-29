# vpc.tf
# Create VPC/Subnet/Security Group/ACL


## create VPC

resource "aws_vpc" "staging_vpc" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
tags = {
    Name = "${var.customer} vpc"
  }
}


## Attach EIP to edge server

resource "aws_eip" "staging_eip" {
  instance = aws_instance.staging-server.id
  vpc      = true
}


## Create Subnet

resource "aws_subnet" "staging_subnet" {
  vpc_id                  = aws_vpc.staging_vpc.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
tags = {
   Name = "${var.customer} subnet"
  }
}


## Create Security Group for edge

resource "aws_security_group" "staging_SG" {
  vpc_id       = aws_vpc.staging_vpc.id
  name         = "${var.customer} Edge"
  description  = "${var.customer} Edge"
ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
}
ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
}
ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
}
ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
}

egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

tags = {
        Name = "Edge_${var.customer}_SG"
  }
}
##Gateway
resource "aws_internet_gateway" "live_GW" {
  vpc_id = aws_vpc.staging_vpc.id
tags = {
        Name = "${var.customer} IG"
    }
}


## Create the Route Table

resource "aws_route_table" "live_route_table" {
    vpc_id = aws_vpc.staging_vpc.id
tags = {
        Name = "${var.customer} Route Table"
    }
}


## Create the Internet Access

resource "aws_route" "live_internet_access" {
  route_table_id        = aws_route_table.live_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.live_GW.id
}


## Associate the Route Table with the Subnet

resource "aws_route_table_association" "live_VPC_association" {
    subnet_id      = aws_subnet.staging_subnet.id
    route_table_id = aws_route_table.live_route_table.id
} #
# end vpc.tf

