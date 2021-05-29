# variables.tf

variable "aws_region" {
         description = "EC2 Region for the VPC"
         default = "ap-south-1"
}
variable "aws_access_key" {
          description = "Ec2 access key"
          default = "AKIAQKRWI6OFYBGKBSWR"
}
variable "aws_secret_key" {
          description = "EC2 secret key"
          default = "FVV5vBmfvn7BolKkThN0lu3ONxXjCNzkpyeSskFz"
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
         default = "11.0.0.0/16"
}
variable "subnetCIDRblock" {
         default = "11.0.3.0/24"
}
variable "destinationCIDRblock" {
         default = "0.0.0.0/0"
}
variable "ingressCIDRblock" {
         type = list
         default = [ "11.0.3.0/24" ]
}
variable "mapPublicIP" {
         default = true
}
variable "ami_id" {
         default = "ami-010aff33ed5991201"
}
variable "instance_type" {
         default = "m5a.large"
}
variable "customer" {
         default = "stagingm24.paragonfootwear.com"
}
variable "ssh-keyname" {
         default = ""
}
variable "key_pair_path" {
         default = "/home/workstation/terraform/stagingm24-paragonfootwear/ssh-keys/id_rsa.pub"
}
# end of variables.tf
