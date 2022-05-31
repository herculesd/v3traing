resource "aws_kms_key" "secret_key" {
  description = "secret-${local.workspace.environment_name}"
}

resource "aws_kms_alias" "secret_key" {
  name          = "alias/secret-${local.workspace.environment_name}"
  target_key_id = aws_kms_key.secret_key.key_id
}