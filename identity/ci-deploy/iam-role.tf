resource "aws_iam_role" "ci_deploy" {
  name               = "CIDeploy"
  assume_role_policy = data.aws_iam_policy_document.assume_role_saml.json
}

resource "aws_iam_role_policy_attachment" "ci_deploy" {
  role       = aws_iam_role.ci_deploy.name
  policy_arn = aws_iam_policy.ci_deploy.arn
}
