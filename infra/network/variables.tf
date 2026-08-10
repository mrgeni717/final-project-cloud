variable "project_slug" {
  description = "Short, lowercase, hyphenated project name used to prefix all resource names"
  type        = string
  default     = "final-project-cloud"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.31.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets (ALB, NAT Gateway)"
  type        = list(string)
  default     = ["172.31.0.0/20", "172.31.16.0/20"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the two private subnets (EKS nodes, RDS)"
  type        = list(string)
  default     = ["172.31.128.0/20", "172.31.144.0/20"]
}
