variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "devopschallenge_dev"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "devops_dev_user"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "key_name" {
  type = string
}
