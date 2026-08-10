variable "project_slug" {
  description = "Short, lowercase, hyphenated project name used to prefix all resource names"
  type        = string
  default     = "final-project-cloud"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes (kept small for cost)"
  type        = string
  default     = "t3.micro"
}

variable "node_desired_size" {
  type    = number
  default = 4
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 4
}
