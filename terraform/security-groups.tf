resource "aws_security_group" "eks_cluster" {

  name        = "${var.project_name}-eks-cluster-sg"
  description = "Security group for EKS Control Plane"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-eks-cluster-sg"
  }
}

resource "aws_security_group" "eks_nodes" {

  name        = "${var.project_name}-eks-node-sg"
  description = "Security group for EKS Worker Nodes"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-eks-node-sg"
  }
}
