resource "aws_ssm_parameter" "ssm_parameter_strings" {
  for_each    = local.workspace.ssm.strings
  name        = each.key
  description = each.key
  type        = "String"
  value       = each.value
}

resource "aws_ssm_parameter" "ssm_parameter_secure_strings" {
  for_each    = toset(local.workspace.ssm.secured_strings)
  name        = each.key
  description = each.key
  type        = "SecureString"
  value       = "NO_VALUE"
  lifecycle {
    ignore_changes = [value]
  }
}
