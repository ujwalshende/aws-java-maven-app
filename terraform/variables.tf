variable "avail_zone" {default="eu-central-1a"}
variable "subnet_cidr_block" {default="10.0.10.0/24"}
variable "vpc_cidr_block" {default="10.0.0.0/16"}
variable "env_prefix" {
    default = "dev"
}
variable "my_ip" {
    default = "24.40.137.170/32"
}
variable "instance_type" {
    default = "t2.micro"
}
variable "region"{
    default = "eu-central-1"
}
variable jenkins_ip{
    default= "164.92.163.142/32"
}