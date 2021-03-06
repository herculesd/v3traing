resource "aws_iam_role" "network_admin" {
  count                = var.create_default_roles ? 1 : 0
  name                 = "NetworkAdministrator"
  assume_role_policy   = data.aws_iam_policy_document.assume_role_saml.json
  max_session_duration = var.role_max_session_duration
}

resource "aws_iam_role_policy_attachment" "network_admin" {
  count      = var.create_default_roles ? 1 : 0
  role       = aws_iam_role.network_admin[0].name
  policy_arn = "arn:aws:iam::aws:policy/job-function/NetworkAdministrator"
}

data "aws_iam_policy_document" "wafv2_admin" {
  statement {
    actions = ["wafv2:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "wafv2_admin" {
  count                = var.create_default_roles ? 1 : 0
  name        = "policy-wafv2-admin"
  description = "WAF V2 Admin Policy"
  policy      = data.aws_iam_policy_document.wafv2_admin.json
}

resource "aws_iam_role_policy_attachment" "wafv2_admin" {
  count                = var.create_default_roles ? 1 : 0
  role       = aws_iam_role.network_admin[0].name
  policy_arn = aws_iam_policy.wafv2_admin[0].arn
}