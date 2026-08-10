# Lets Kubernetes ServiceAccounts assume specific IAM roles (IRSA).
# We don't use this yet, but it's tied to the cluster resource, so we
# set it up now — Phase 7 (ALB Ingress Controller) will need it.
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}
