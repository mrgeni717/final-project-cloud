# --- IAM role the EKS control plane assumes ---
resource "aws_iam_role" "cluster" {
  name = "${var.project_slug}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# --- The EKS control plane ---
resource "aws_eks_cluster" "main" {
  name     = "${var.project_slug}-eks"
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = concat(
      data.terraform_remote_state.network.outputs.private_subnet_ids,
      data.terraform_remote_state.network.outputs.public_subnet_ids,
    )
    # Attach our own SG too, alongside the one EKS creates automatically
    security_group_ids     = [data.terraform_remote_state.network.outputs.nodes_security_group_id]
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  # Needed so EKS Access Entries (used by the GitHub Actions IAM role)
  # can be created. API_AND_CONFIG_MAP keeps backward compatibility
  # with the legacy aws-auth ConfigMap while adding support for the
  # newer Access Entry API.
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}
