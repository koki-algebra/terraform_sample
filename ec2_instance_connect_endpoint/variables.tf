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

variable "db_port" {
  type        = number
  description = "Port number for RDS"
  default     = 5432
}

variable "db_engine" {
  type        = string
  description = "Database engine"
  default     = "aurora-postgresql"
}

variable "db_engine_version" {
  type        = string
  description = "Version of database engine"
  default     = "15.3"
}

variable "db_database_name" {
  type        = string
  description = "Database name"
  default     = "app"
}

variable "db_instance_class" {
  type        = string
  description = "Database Instance class"
  default     = "db.t4g.medium"
}

# Secrets
variable "db_user" {
  type        = string
  description = "Database user"
}

variable "db_password" {
  type        = string
  description = "Database password"
}
