resource "aws_ebs_encryption_by_default" "default" {
  count   = local.workspace.ebs_encryption_by_default.enabled ? 1 : 0
  enabled = true
}
