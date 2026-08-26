variable "project_slug" {
  description = "Short, lowercase, hyphenated project name used to prefix all resource names"
  type        = string
  default     = "final-project-cloud"
}

variable "db_name" {
  description = "MySQL database name (letters/numbers/underscores only, no hyphens)"
  type        = string
  default     = "finalprojectcloud"
}

variable "db_instance_class" {
  description = "RDS instance class — kept at the Free Tier–eligible size"
  type        = string
  default     = "db.t3.micro"
}
