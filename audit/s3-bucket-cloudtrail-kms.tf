
data "aws_iam_policy_document" "kms_policy_cloudtrail" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = formatlist("arn:aws:cloudtrail:*:%s:trail/*", concat(
        [data.aws_caller_identity.current.account_id],
        local.workspace.logs_buckets.allow_from_account_ids
      ))
    }
  }
  statement {
    sid    = "Allow CloudWatch Access"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Allow Describe Key access"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com", "lambda.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }
}

resource "aws_kms_key" "cloudtrail" {
  deletion_window_in_days = 7
  description             = "CloudTrail Log Encryption Key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_policy_cloudtrail.json
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/${local.workspace.org_name}-cloudtrail"
  target_key_id = aws_kms_key.cloudtrail.key_id
}

output "cloudtrail_kms_key_arn" {
  value = aws_kms_key.cloudtrail.arn
}

output "cloudtrail_kms_key_id" {
  value = aws_kms_key.cloudtrail.id
}