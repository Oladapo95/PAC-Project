# VPC CIDR 
variable "aws_vpc" {
  default = "10.0.0.0/16"
}

#Public Subnet 1
variable "aws_pubsub01" {
  default = "10.0.1.0/24"
}

#Public Subnet 2
variable "aws_pubsub02" {
  default = "10.0.2.0/24"
}

#Private Subnet 1
variable "aws_prvsub01" {
  default = "10.0.3.0/24"
}

#Private Subnet 2
variable "aws_prvsub02" {
  default = "10.0.4.0/24"
}

#All IP CIDR
variable "all_ip" {
  default = "0.0.0.0/0"
}

#Key pair name
variable "key_name" {
  default = "pacpet1-key"
}

#Path to public key pair
variable "pacpet1_keypair_path" {
  default = "/Users/dapo/Desktop/AWS Classes/Projects/PAC-Project-Mine/pacpet1-key.pub"
}



