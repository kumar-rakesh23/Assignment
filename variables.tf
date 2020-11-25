variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default     = "terraform"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-south-1"
}

variable "vpc_name" {
  description = "AWS VPC to launch servers."
  default     = "tf_test_vpc"
}

variable "subnet_name" {
  description = "AWS Subnet Name."
  default     = "tf_test_subnet"
}

variable "IG_name" {
  description = "AWS Internet Gateway Name."
  default     = "tf_test_ig"
}

variable "routetable_name" {
  description = "AWS Route Table Name."
  default     = "tf_route_table"
}

variable "sg_name" {
  description = "AWS Default Security Group Name."
  default     = "tf_instance_sg"
}

variable "elbsg_name" {
  description = "AWS ELB Security Group Name."
  default     = "tf_elb_sg"
}

variable "elb_name" {
  description = "AWS ELB Name."
  default     = "tf-test-elb"
}

variable "instance_name" {
  description = "AWS Instance Name."
  default     = "tf-example"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "health_check_type" {
  default = "EC2"
}

variable "health_check_grace_period" {
  default = "300"
}

variable "asg_min" {
  default = "2"
}

variable "asg_max" {
  default = "4"
}

# ubuntu-(x64)
variable "aws_amis" {
  default = {
    "ap-south-1" = "ami-0a4a70bd98c6d6441"
    "us-east-1" = "ami-0885b1f6bd170450c"
  }
}
