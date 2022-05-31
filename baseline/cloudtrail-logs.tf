resource "aws_iam_role" "cloudtrail_logs" {
  count       = local.workspace.cloudtrail.enabled ? 1 : 0
  name_prefix = "CloudtrailLogsServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  count       = local.workspace.cloudtrail.enabled ? 1 : 0
  name_prefix = "cloudwatch_"
  role        = aws_iam_role.cloudtrail_logs[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailPutLogEvents20141101",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_kms_key" "cloudtrail_cloudwatch_logs" {
  count                   = local.workspace.cloudtrail.enabled ? 1 : 0
  deletion_window_in_days = 7
  description             = "CloudTrail CW Logs Encryption Key"
  enable_key_rotation     = true

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        ]
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow CloudTrail to encrypt logs",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "kms:GenerateDataKey*",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "kms:EncryptionContext:aws:cloudtrail:arn": [
            "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          ]
        }
      }
    },
    {
      "Sid": "Allow CloudWatch Access",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow Describe Key access",
      "Effect": "Allow",
      "Principal": {
        "Service": ["cloudtrail.amazonaws.com", "lambda.amazonaws.com"]
      },
      "Action": "kms:DescribeKey",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  count             = local.workspace.cloudtrail.enabled ? 1 : 0
  name              = "${local.workspace.org_name}-cloudtrail"
  kms_key_id        = aws_kms_key.cloudtrail_cloudwatch_logs[0].arn
  retention_in_days = local.workspace.cloudtrail.log_group_retention_in_days
}