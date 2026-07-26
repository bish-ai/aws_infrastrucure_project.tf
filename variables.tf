variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}


variable "project_name" {
  description = "Project name"
  type        = string
  default     = "terraform-aws-project"
}


variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string    
  default     = "10.0.0.0/16"
}


variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}


variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)

  default = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}


variable "ami_id" {
  description = "Amazon Linux AMI ID"
  type        = string
  default     = "ami-0abcdef123456789"
}