data "aws_iam_policy_document" "s3_policy_logs" {
  statement {
    sid    = "CWLogs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${local.workspace.org_name}-audit-logs-${data.aws_region.current.name}/*"
    ]
  }
  statement {
    sid    = "OrgAccounts"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", local.workspace.logs_buckets.allow_from_account_ids)
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${local.workspace.org_name}-audit-logs-${data.aws_region.current.name}/*"
    ]
  }
  statement {
    sid    = "OrgAccountsAcl"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", local.workspace.logs_buckets.allow_from_account_ids)
    }
    actions = [
      "s3:GetBucketAcl",
      "s3:PutBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::${local.workspace.org_name}-audit-logs-${data.aws_region.current.name}"
    ]
  }
  statement {
    sid    = "CWLogsAcl"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::${local.workspace.org_name}-audit-logs-${data.aws_region.current.name}"
    ]
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.workspace.org_name}-audit-logs-${data.aws_region.current.name}"
  acl    = "private"
  policy = data.aws_iam_policy_document.s3_policy_logs.json

  lifecycle {
    ignore_changes = [
      versioning,
      grant
    ]
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

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

resource "aws_s3_bucket_public_access_block" "logs_s3_public_access_block" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "logs_s3_bucket_name" {
  value = aws_s3_bucket.logs.id
}

output "logs_s3_bucket_arn" {
  value = aws_s3_bucket.logs.arn
}