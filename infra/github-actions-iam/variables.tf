variable "project_slug" {
  description = "Short, lowercase, hyphenated project name used to prefix all resource names"
  type        = string
  default     = "final-project-cloud"
}

variable "github_repo" {
  description = "GitHub repo in org/name form, scoped so only this exact repo (and only pushes to main) can assume the role"
  type        = string
  default     = "mrgeni717/final-project-cloud"
}

variable "eks_cluster_name" {
  type    = string
  default = "final-project-cloud-eks"
}
