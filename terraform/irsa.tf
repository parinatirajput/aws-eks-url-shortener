#############################
# OIDC Provider
#############################

data "aws_iam_openid_connect_provider" "eks" {
  url = "https://oidc.eks.us-east-2.amazonaws.com/id/74321ACA379886F867BC28BAEC3B2E2D"
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
          Federated = data.aws_iam_openid_connect_provider.eks.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/74321ACA379886F867BC28BAEC3B2E2D:sub" = "system:serviceaccount:url-shortener:url-shortener-sa"
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
