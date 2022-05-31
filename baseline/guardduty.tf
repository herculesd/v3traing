module "guardduty" {
  count               = local.workspace.guardduty.enabled ? 1 : 0
  source              = "git::https://github.com/DNXLabs/terraform-aws-guardduty.git?ref=1.0.0"
  admin_account_id    = try(local.workspace.guardduty.admin_account_id, "")
  alarm_slack_webhook = local.workspace.guardduty.alarms.enabled ? try(local.workspace.guardduty.alarms.slack_endpoint, "") : ""
}
