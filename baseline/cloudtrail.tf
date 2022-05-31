resource "aws_cloudtrail" "default" {
  count = local.workspace.cloudtrail.enabled ? 1 : 0

  name                          = "${local.workspace.org_name}-cloudtrail"
  include_global_service_events = local.workspace.cloudtrail.global
  is_multi_region_trail         = local.workspace.cloudtrail.global
  enable_log_file_validation    = true

  s3_bucket_name = local.workspace.cloudtrail.s3_bucket_name
  kms_key_id     = local.workspace.cloudtrail.kms_key_arn

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_logs[0].arn
}