module "notification" {
  source = "git::https://github.com/DNX-BR/terraform-aws-lambda-notification.git"
  
  endpoint_type  = local.workspace.notifications.endpoint_type
  webhook_google = local.workspace.notifications.webhook_google
}

