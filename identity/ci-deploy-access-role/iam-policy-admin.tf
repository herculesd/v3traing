
data "aws_iam_policy_document" "ci_deploy_access_admin" {
  statement {
    sid       = "admin"
    actions   = ["*"]
    resources = ["*"]
  }
}
