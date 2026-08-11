# IAM permissions alone (eks:DescribeCluster) only let the role fetch
# cluster connection info — actually running kubectl commands requires
# separate Kubernetes-level authorization, granted here via EKS Access
# Entries (the modern replacement for manually editing the aws-auth
# ConfigMap).
resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.github_actions.arn
}

resource "aws_eks_access_policy_association" "github_actions_edit" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.github_actions.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["default"]
  }

  # Undocumented but real: this resource can be created before the
  # access entry it depends on unless we force the order explicitly.
  depends_on = [aws_eks_access_entry.github_actions]
}
