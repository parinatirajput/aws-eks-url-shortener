output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
output "eks_cluster_role_arn" {

  value = aws_iam_role.eks_cluster_role.arn

}

output "eks_node_role_arn" {

  value = aws_iam_role.eks_node_role.arn

}

output "cluster_name" {

  value = aws_eks_cluster.main.name

}

output "cluster_endpoint" {

  value = aws_eks_cluster.main.endpoint

}
