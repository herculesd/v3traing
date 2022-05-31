module "cloudtrail_alarms" {
  count  = local.workspace.cloudtrail.enabled && local.workspace.cloudtrail.alarms.enabled ? 1 : 0
  source = "git::https://github.com/DNXLabs/terraform-aws-security-alarms.git?ref=1.2.0"

  org_name                  = local.workspace.org_name
  account_name              = terraform.workspace
  enable_alarm_baseline     = true
  enable_chatbot_slack      = false
  alarm_account_ids         = [data.aws_caller_identity.current.account_id]
  alarm_mode                = try(local.workspace.cloudtrail.alarms.mode, "light")
  cloudtrail_log_group_name = try(aws_cloudwatch_log_group.cloudtrail[0].name, "")
}

resource "aws_sns_topic_subscription" "cloudtrail_alarm_email" {
  count = (local.workspace.cloudtrail.enabled &&
    local.workspace.cloudtrail.alarms.enabled &&
  try(local.workspace.cloudtrail.alarms.email, "") != "") ? 1 : 0
  topic_arn = module.cloudtrail_alarms[0].alarm_sns_topic[0].arn
  protocol  = "email"
  endpoint  = try(local.workspace.cloudtrail.alarms.email, "")
}

module "cloudtrail_alarms_sns_slack" {
  count = (local.workspace.cloudtrail.enabled &&
    local.workspace.cloudtrail.alarms.enabled &&
  try(local.workspace.cloudtrail.alarms.slack_endpoint, "") != "") ? 1 : 0
  source = "git::https://github.com/DNXLabs/terraform-aws-sns.git?ref=0.2.0"

  sns_topic_arn  = module.cloudtrail_alarms[0].alarm_sns_topic[0].arn
  slack_endpoint = try(local.workspace.cloudtrail.alarms.slack_endpoint, "")
}
