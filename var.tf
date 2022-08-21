variable "region" {
    description = "my aws region"
    default     = "us-west-1"
}


variable "image" {
    description = "my aws ami"
    default     = "ami-0d70546e43a941d70"
}


variable "type" {
    description = "my aws instance type"
    default     = "t2.micro"
}
