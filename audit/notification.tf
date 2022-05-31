module "notifications" {
  count  = local.workspace.notifications.enabled ? 1 : 0
  source = "git::https://github.com/DNXLabs/terraform-aws-sns.git?ref=0.2.0"

  sns_topic_name     = local.workspace.org_name
  slack_endpoint     = try(local.workspace.notifications.slack_endpoint, "")
  email              = try(local.workspace.notifications.email, "")
  account_ids        = local.workspace.notifications.allow_from_account_ids
  sns_kms_encryption = true
}

output "notifications_sns_topic_arn" {
  value = try(module.notifications[0].aws_sns_topic_arn, "")
}