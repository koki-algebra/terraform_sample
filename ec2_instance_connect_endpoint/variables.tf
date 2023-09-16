variable "project_name" {
  type        = string
  description = "Project name"
  default     = "eice_sample"
}

variable "instance_ami" {
  type        = string
  description = "EC2 instance AMI"
  default     = "ami-04cb4ca688797756f" # Amazon Linux 2023
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}
