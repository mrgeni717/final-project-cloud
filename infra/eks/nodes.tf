# --- IAM role the worker node EC2 instances assume ---
resource "aws_iam_role" "node" {
  name = "${var.project_slug}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_readonly" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# --- Launch template: this is what lets us attach our OWN security
#     group (from Phase 3, ALB-only ingress) to the actual worker
#     EC2 instances, instead of relying only on the SG EKS creates
#     automatically. We must include the cluster's own security group
#     here too, or nodes won't be able to reach the control plane. ---
resource "aws_launch_template" "nodes" {
  name_prefix   = "${var.project_slug}-node-"
  instance_type = var.node_instance_type

  vpc_security_group_ids = [
    aws_eks_cluster.main.vpc_config[0].cluster_security_group_id,
    data.terraform_remote_state.network.outputs.nodes_security_group_id,
  ]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_slug}-eks-node"
    }
  }
}

# --- The managed node group itself ---
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_slug}-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = data.terraform_remote_state.network.outputs.private_subnet_ids

  launch_template {
    id      = aws_launch_template.nodes.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_readonly,
  ]
}
