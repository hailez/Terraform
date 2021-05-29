# variables.tf

variable "aws_region" {
         description = "EC2 Region for the VPC"
         default = "ap-south-1"
}
variable "aws_access_key" {
          description = "Ec2 access key"
          default = "AKIAQ5N4N63RXJTLM2V7"
}
variable "aws_secret_key" {
          description = "EC2 secret key"
          default = "maraYwZxtcFHLMuBHgU2jSr1T52R7dwHOpREve8h"
}
variable "availabilityZone" {
         default = "ap-south-1b"
}
variable "instanceTenancy" {
         default = "default"
}
variable "dnsSupport" {
         default = true
}
variable "dnsHostNames" {
         default = true
}
variable "vpcCIDRblock" {
         default = "10.0.0.0/16"
}
variable "subnetCIDRblock" {
         default = "10.0.1.0/24"
}
variable "destinationCIDRblock" {
         default = "0.0.0.0/0"
}
variable "ingressCIDRblock" {
 #        type = "list"
         default = [ "10.0.1.0/24" ]
}
variable "mapPublicIP" {
         default = true
}
variable "ami_id" {
         default = "ami-010aff33ed5991201"
}
variable "edge_instance_type" {
         default = "m5a.large"
}
variable "db_instance_type" {
         default = "m5a.2xlarge"
}
variable "app_instance_type" {
         default = "c5.large"
}

variable "customer" {
         default = "thebodyshop"
}
variable "ssh-keyname" {
         default = ""
}
variable "key_pair_path" {
         default = "/home/workstation/terraform/thebodyshop/ssh-keys/id_rsa.pub"
}
# end of variables.tf

