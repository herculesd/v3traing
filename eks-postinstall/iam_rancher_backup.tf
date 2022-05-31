data "aws_iam_policy_document" "rancher_s3" {
  count      = local.workspace.rancher_backup.enable ? 1 : 0
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = ["${aws_s3_bucket.rancher[0].arn}"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.rancher[0].arn}/*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.rancher_s3[0].arn]
    effect    = "Allow"
  } 
}
      
data "aws_iam_policy_document" "rancher_assume" {
  count      = local.workspace.rancher_backup.enable ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.workspace.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(local.workspace.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:cattle-resources-system:rancher-backup"]
    }
  }
}

resource "aws_iam_role" "rancher" {
  count      = local.workspace.rancher_backup.enable ? 1 : 0
  name               = "role-rancher-s3-${local.workspace.environment_name}"
  assume_role_policy = data.aws_iam_policy_document.rancher_assume[0].json
}

resource "aws_iam_policy" "rancher" {
  count      = local.workspace.rancher_backup.enable ? 1 : 0
  name        = "policy-rancher-${local.workspace.environment_name}"
  description = "Policy rancher access s3 for backup"
  policy      = data.aws_iam_policy_document.rancher_s3[0].json
}

resource "aws_iam_role_policy_attachment" "rancher" {
  count      = local.workspace.rancher_backup.enable ? 1 : 0
  role       = aws_iam_role.rancher[0].name
  policy_arn = aws_iam_policy.rancher[0].arn
}
