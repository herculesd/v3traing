
data "aws_iam_policy_document" "s3_policy_guardduty" {
  statement {
    sid       = "Allow PutObject"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.workspace.org_name}-audit-guardduty-${data.aws_region.current.name}/*"]
    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }
  statement {
    sid       = "Allow GetBucketLocation"
    actions   = ["s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::${local.workspace.org_name}-audit-guardduty-${data.aws_region.current.name}"]
    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }
  statement {
    sid       = "Deny incorrect encryption header"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.workspace.org_name}-audit-guardduty-${data.aws_region.current.name}/*"]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [aws_kms_key.s3_guardduty.arn]
    }
    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }
  statement {
    sid       = "Deny non-HTTPS access"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${local.workspace.org_name}-audit-guardduty-${data.aws_region.current.name}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}


data "aws_iam_policy_document" "s3_guardduty_kms" {
  statement {
    sid       = "Allow GuardDuty to encrypt findings"
    actions   = ["kms:GenerateDataKey"]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }
  statement {
    sid       = "Allow account to manage key"
    actions   = ["kms:*"]
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_kms_key" "s3_guardduty" {
  description             = "Guardduty S3 Key"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.s3_guardduty_kms.json
}

resource "aws_s3_bucket" "guardduty" {
  bucket = "${local.workspace.org_name}-audit-guardduty-${data.aws_region.current.name}"
  acl    = "private"
  policy = data.aws_iam_policy_document.s3_policy_guardduty.json

  lifecycle_rule {
    id      = "ARCHIVING"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = local.workspace.logs_buckets.transition_to_glacier_in_days
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "guardduty_s3_public_access_block" {
  bucket = aws_s3_bucket.guardduty.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "guardduty_s3_bucket_name" {
  value = aws_s3_bucket.guardduty.id
}

output "guardduty_s3_bucket_arn" {
  value = aws_s3_bucket.guardduty.arn
}