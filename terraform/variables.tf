variable "region" {
  type    = string
  default = "us-east-1"
}
############# For OPS Server #################
# 


variable "availability_zone" {
  type    = string
  default = "us_east_1a"
}

variable "vpc_cidr" {
  type    = string
  default = "172.22.0.0/16"
}

variable "ops_subnet_cidr" {
  type    = string
  default = "172.22.1.0/24"
}

variable "ssh_key_path" {
  type    = string
  default = "/home/hro/.ssh/for_tf.pub"
}

#############for EKS Cluster ############## 

variable "subnet_cidr_1" {
  type    = string
  default = "172.22.10.0/24"
}

variable "subnet_cidr_2" {
  type    = string
  default = "172.22.20.0/24"
}

variable "availability_zone_1" {
  type    = string
  default = "us-east-1c"
}

variable "availability_zone_2" {
  type    = string
  default = "us-east-1b"
}

variable "app_port" {
  type    = number
  default = 30000
}


############# for DB instance ##########

variable "db_subnet_cidr_1" {
  type    = string
  default = "172.22.100.0/24"
}

variable "db_subnet_cidr_2" {
  type    = string
  default = "172.22.101.0/24"
}

variable "sql_password" {
  type = string
  default = "sql_password"
}

############## for Route53 ###########

variable "dns_zone_id" {
  default = "zone_id"
  type    = string
}