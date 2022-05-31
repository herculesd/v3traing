module "log_exporter" {
  count                         = local.workspace.log_exporter.enabled ? 1 : 0
  source                        = "git::https://github.com/DNXLabs/terraform-aws-log-exporter.git?ref=1.0.1"
  cloudwatch_logs_export_bucket = try(local.workspace.log_exporter.cloudwatch_logs_export_bucket, "")
}
