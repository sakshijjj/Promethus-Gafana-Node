variable "instance_type" {
  description = "EC2 instance type."
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key name to use for the instance."
  type        = string
}

variable "ami_id" {
  description = "The ID of the AMI to use for the instance, ensure it is compatible with your region."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with."
  type        = list(string)
}

variable "subnet_id" {
  description = "The VPC subnet ID."
  type        = string
}
