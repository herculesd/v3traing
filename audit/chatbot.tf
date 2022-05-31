module "chatbot_alarms" {
  count  = local.workspace.chatbot.enabled ? 1 : 0
  source = "git::https://github.com/DNXLabs/terraform-aws-chatbot?ref=2.0.0"

  enabled              = true
  org_name             = local.workspace.org_name
  workspace_name       = terraform.workspace
  slack_channel_id     = local.workspace.chatbot.slack_channel_id
  slack_workspace_id   = local.workspace.chatbot.slack_workspace_id
  alarm_sns_topic_arns = [aws_sns_topic.chatbot[0].arn]
}

resource "aws_sns_topic" "chatbot" {
  count = local.workspace.chatbot.enabled ? 1 : 0
  name  = "${local.workspace.org_name}-chatbot"
}