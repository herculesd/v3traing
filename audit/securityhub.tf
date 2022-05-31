
module "securityhub" {
  count  = local.workspace.securityhub.enabled ? 1 : 0
  source = "git::https://github.com/DNXLabs/terraform-aws-securityhub.git?ref=0.1.0"

  subscription_pci          = local.workspace.securityhub.subscriptions.pci
  subscription_cis          = local.workspace.securityhub.subscriptions.cis
  subscription_foundational = local.workspace.securityhub.subscriptions.foundational
  members                   = local.workspace.securityhub.members
  alarm_email               = local.workspace.securityhub.alarms.enabled ? try(local.workspace.securityhub.alarms.email, "") : ""
  alarm_slack_endpoint      = local.workspace.securityhub.alarms.enabled ? try(local.workspace.securityhub.alarms.slack_endpoint, "") : ""
}
