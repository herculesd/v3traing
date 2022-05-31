resource "aws_securityhub_account" "default" {
  count = local.workspace.securityhub.enabled ? 1 : 0
}

resource "aws_securityhub_invite_accepter" "default" {
  count     = local.workspace.securityhub.enabled && length(try(local.workspace.securityhub.admin_account_id, "")) != 0 ? 1 : 0
  master_id = local.workspace.securityhub.admin_account_id
  depends_on = [
    aws_securityhub_account.default
  ]
}
