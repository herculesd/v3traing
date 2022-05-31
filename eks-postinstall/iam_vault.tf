data "aws_iam_policy_document" "secret" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["arn:aws:kms:${local.workspace.aws_region}:${local.workspace.aws.account_id}:key/*"]
    effect    = "Allow"
  }
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.workspace.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(local.workspace.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:vault:vault"]
    }
  }
}


resource "aws_iam_role" "secret" {
  name               = "${local.workspace.environment_name}-secret"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}


resource "aws_iam_policy" "secret" {
  name        = "${local.workspace.environment_name}-secret"
  description = "Policy for secret service"
  policy      = data.aws_iam_policy_document.secret.json
}


resource "aws_iam_role_policy_attachment" "secret" {
  role       = aws_iam_role.secret.name
  policy_arn = aws_iam_policy.secret.arn
}
