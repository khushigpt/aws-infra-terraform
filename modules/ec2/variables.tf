variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "my_ip" {
  description = "Your IP for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "subnet_id" {
  description = "Subnet ID where EC2 will be launched"
  type        = string
}
