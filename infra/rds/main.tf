# We deliberately do NOT pin engine_version — AWS RDS automatically
# uses its current latest-supported MySQL version when it's omitted.
# This avoids the exact problem we hit with the EKS Kubernetes version
# (a hardcoded version falling out of support mid-project).
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_slug}-db-subnet-group"
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project_slug}-mysql"
  engine         = "mysql"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = "appadmin"

  # AWS generates and stores the password in Secrets Manager — it never
  # exists in Terraform state, in this codebase, or in Git.
  manage_master_user_password = true

  db_subnet_group_name  = aws_db_subnet_group.main.name
  vpc_security_group_ids = [data.terraform_remote_state.network.outputs.db_security_group_id]

  multi_az             = false # single-AZ — matches the cost-conscious sizing used throughout
  publicly_accessible  = false # only reachable from inside the VPC (EKS nodes), never the internet

  backup_retention_period = 1
  skip_final_snapshot     = true # easy teardown for a capstone; wouldn't do this in real production
  deletion_protection     = false
  apply_immediately       = true
}
