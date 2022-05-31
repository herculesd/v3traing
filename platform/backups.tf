module "backups" {
  count  = local.workspace.backups.enabled ? 1 : 0
  source = "git::https://github.com/DNXLabs/terraform-aws-backup?ref=1.0.2"

  # Backup name
  name = "${try(local.workspace.backups.name, terraform.workspace)}-daily"
  # Rule
  rule_schedule = try(local.workspace.backups.rule_schedule, "")
}
