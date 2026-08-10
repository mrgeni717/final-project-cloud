# --- ALB: open to the internet on 80/443, nothing else ---
resource "aws_security_group" "alb" {
  name        = "${var.project_slug}-alb-sg"
  description = "Allow inbound HTTP/HTTPS from the internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_slug}-alb-sg" }
}

# --- EKS worker nodes / pods: only reachable from the ALB ---
resource "aws_security_group" "nodes" {
  name        = "${var.project_slug}-nodes-sg"
  description = "Allow inbound traffic only from the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Traffic from ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Nodes need to talk to each other (pod-to-pod, kubelet, etc.)
  ingress {
    description = "Node to node"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_slug}-nodes-sg"
    # Lets the EKS control plane manage this SG for the cluster
    "kubernetes.io/cluster/${var.project_slug}-eks" = "owned"
  }
}

# --- RDS: only reachable from the EKS nodes, on the MySQL port ---
resource "aws_security_group" "db" {
  name        = "${var.project_slug}-db-sg"
  description = "Allow MySQL traffic only from EKS nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.nodes.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_slug}-db-sg" }
}
