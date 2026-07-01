variable "aws_region" {

  default = "us-east-2"

}

variable "project_name" {

  default = "url-shorterner"

}

variable "vpc_cidr" {

  default = "10.0.0.0/16"

}

variable "availability_zones" {
  default = [
    "us-east-2a",
    "us-east-2b"
  ]
}

variable "public_subnets" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "cluster_version" {
  default = "1.33"
}

variable "node_instance_type" {
  default = "t3.micro"
}

variable "desired_size" {
  default = 2
}

variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 3
}
