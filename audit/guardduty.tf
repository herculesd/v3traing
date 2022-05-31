resource "aws_guardduty_detector" "master" {
  count  = local.workspace.guardduty.enabled ? 1 : 0
  enable = true
}

resource "aws_guardduty_publishing_destination" "guardduty" {
  count           = local.workspace.guardduty.enabled ? 1 : 0
  detector_id     = aws_guardduty_detector.master[0].id
  destination_arn = aws_s3_bucket.guardduty.arn
  kms_key_arn     = aws_kms_key.s3_guardduty.arn
}

resource "aws_guardduty_member" "member" {
  for_each = { for member in local.workspace.securityhub.members : member.account_id => member }

  account_id  = each.value.account_id
  detector_id = aws_guardduty_detector.master[0].id
  email       = each.value.email
  invite      = true
}