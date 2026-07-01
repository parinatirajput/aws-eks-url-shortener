#############################
# EKS OIDC Certificate
#############################

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

#############################
# OIDC Provider
#############################

resource "aws_iam_openid_connect_provider" "eks" {

  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]

  tags = {
    Name = "url-shortener-oidc"
  }

  depends_on = [
    aws_eks_cluster.main
  ]
}

#############################
# DynamoDB Policy
#############################

resource "aws_iam_policy" "url_shortener_dynamodb" {

  name        = "URLShortenerDynamoDBPolicy"
  description = "Allow Flask application to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]

        Resource = "arn:aws:dynamodb:us-east-2:352435704376:table/url-shortener"
      }
    ]
  })
}

#############################
# IRSA Role
#############################

resource "aws_iam_role" "url_shortener_irsa" {

  name = "url-shortener-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
            Federated = aws_iam_openid_connect_provider.eks.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"
       Condition = {
           StringEquals = {
    "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:url-shortener:url-shortener-sa"

    "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
  }
}
      }
    ]
  })
}

#############################
# Attach Policy
#############################

resource "aws_iam_role_policy_attachment" "irsa_policy" {

  role       = aws_iam_role.url_shortener_irsa.name
  policy_arn = aws_iam_policy.url_shortener_dynamodb.arn
}

#############################
# Output
#############################

output "irsa_role_arn" {
  value = aws_iam_role.url_shortener_irsa.arn
}
