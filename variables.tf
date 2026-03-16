variable "aws_region" {
    description = "AWS region to deploy resources"
    type        = string
    default     = "ap-south-1"
}

variable "project_name" {
    description = "Name prefix for all resources"                          
    type        = string                                                    
    default     = "khushi-devops"                                              
}                                                                           
 variable "environment" {
    description = "Environment name"                          
    type        = string                                                    
    default     = "dev"                                              
}                                                                           

variable "vpc_cidr" {
    description = "CIDR block for VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR block for public subnet"
    type        = string
    default     = "10.0.0.0/24"
}

variable "instance_type" {
    description = "EC2 instance type"
    type        = string
    default     = "t2.micro"
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type = string
  default = "0.0.0.0/0"
}
