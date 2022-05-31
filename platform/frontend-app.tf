resource "aws_s3_bucket" "frontend_app" {
  for_each      = { for app in local.workspace.frontend.apps : app.name => app }
  bucket_prefix = "${each.value.name}-${each.value.environment_name}"
  acl           = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = try(each.value.kms_key_arn, "")
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

module "frontend_app" {
  for_each = { for app in local.workspace.frontend.apps : app.name => app }
  source   = "git::https://github.com/DNXLabs/terraform-aws-static-app.git?ref=2.3.0"

  name            = "${each.value.name}-${each.value.environment_name}"
  s3_bucket_id    = aws_s3_bucket.frontend_app[each.key].id
  hostnames       = each.value.hostnames
  hostname_create = each.value.hostname_create
  certificate_arn = can(each.value.certificate) ? module.acm_certificate_global[each.value.certificate].arn : try(each.value.certificate_arn, "")
  hosted_zone     = each.value.hosted_zone
}
