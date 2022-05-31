data "aws_iam_policy_document" "assume_role_ci_deploy_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = var.trust_arns
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "ci_deploy_access" {
  name   = "ci-deploy"
  policy = data.aws_iam_policy_document.ci_deploy_access.json
}

resource "aws_iam_policy" "ci_deploy_access_admin" {
  count  = var.is_admin ? 1 : 0
  name   = "ci-deploy-admin"
  policy = data.aws_iam_policy_document.ci_deploy_access_admin.json
}

resource "aws_iam_role" "ci_deploy_access" {
  name               = "CIDeployAccess"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ci_deploy_access.json
}

resource "aws_iam_role_policy_attachment" "ci_deploy_access" {
  role       = aws_iam_role.ci_deploy_access.name
  policy_arn = aws_iam_policy.ci_deploy_access.arn
}

resource "aws_iam_role_policy_attachment" "ci_deploy_access_admin" {
  count      = var.is_admin ? 1 : 0
  role       = aws_iam_role.ci_deploy_access.name
  policy_arn = aws_iam_policy.ci_deploy_access_admin[0].arn
}

output "ci_deploy_access_role_arn" {
  value = aws_iam_role.ci_deploy_access.arn
}
