locals {
  # The OIDC provider URL comes back as "https://oidc.eks...", but IAM
  # condition keys need it WITHOUT the "https://" prefix.
  oidc_provider_host = replace(data.terraform_remote_state.eks.outputs.oidc_provider_url, "https://", "")
}

resource "aws_iam_policy" "alb_controller" {
  name   = "final-project-cloud-alb-controller-policy"
  policy = file("${path.module}/iam_policy.json")
}

# Trust policy: only the Kubernetes ServiceAccount named
# "aws-load-balancer-controller" in the "kube-system" namespace is
# allowed to assume this role (IRSA — IAM Roles for Service Accounts).
resource "aws_iam_role" "alb_controller" {
  name = "final-project-cloud-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = data.terraform_remote_state.eks.outputs.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider_host}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          "${local.oidc_provider_host}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}
