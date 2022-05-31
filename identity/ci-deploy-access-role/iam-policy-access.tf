
data "aws_iam_policy_document" "ci_deploy_access" {
  statement {
    sid = "staticapps"
    actions = [
      "s3:*",
      "cloudfront:CreateInvalidation",
    ]
    resources = ["*"]
  }
  statement {
    sid = "ecsecr"
    actions = [
      "ecs:Describe*",
      "ecs:List*",
      "ecs:RunTask",
      "ecs:RegisterTaskDefinition",
      "codedeploy:CreateDeployment",
      "codedeploy:Get*",
      "codedeploy:List*",
      "codedeploy:ContinueDeployment",
      "codedeploy:StopDeployment",
      "codedeploy:RegisterApplicationRevision",
      "ecr:*",
    ]
    resources = ["*"]
  }
  statement {
    sid = "eks"
    actions = [
      "eks:Describe*",
      "eks:List*",
      "eks:UpdateClusterConfig"
    ]
    resources = ["*"]
  }
  statement {
    sid = "elb"
    actions = [
      "elasticloadbalancing:Describe*",
    ]
    resources = ["*"]
  }
  statement {
    sid = "logs"
    actions = [
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogDelivery",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults",
      "logs:FilterLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:TestMetricFilter",
    ]
    resources = ["*"]
  }
  statement {
    sid = "ecspassrole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/ecs-task-*"
    ]
  }
}
