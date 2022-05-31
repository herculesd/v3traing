resource "aws_iam_account_alias" "alias" {
  count         = local.workspace["account_alias"] ? 1 : 0
  account_alias = "${local.workspace["org_name"]}-${local.workspace["account_name"]}"
}