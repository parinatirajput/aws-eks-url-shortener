resource "aws_eks_cluster" "main" {

  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  version = var.cluster_version

  vpc_config {

    subnet_ids = aws_subnet.public[*].id

    security_group_ids = [
      aws_security_group.eks_cluster.id
    ]

    endpoint_private_access = false
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

resource "aws_eks_node_group" "main" {

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-nodes"

  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = aws_subnet.public[*].id

  instance_types = [
    var.node_instance_type
  ]

  scaling_config {

    desired_size = var.desired_size

    min_size = var.min_size

    max_size = var.max_size
  }

  capacity_type = "ON_DEMAND"

  ami_type = "AL2023_x86_64_STANDARD"

  depends_on = [

    aws_iam_role_policy_attachment.worker_node_policy,

    aws_iam_role_policy_attachment.cni_policy,

    aws_iam_role_policy_attachment.ecr_policy,

    aws_eks_cluster.main

  ]

  tags = {

    Name = "${var.project_name}-nodes"

  }
}
