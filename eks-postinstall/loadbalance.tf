locals {
  wafv2_acl_arn = length(try(data.aws_wafv2_web_acl.waf_alb.arn, "")) > 0 ? data.aws_wafv2_web_acl.waf_alb.arn : "#"
}

resource "kubectl_manifest" "load_balance_internal" {
  depends_on = [module.load_balancer_controller]
  yaml_body  = templatefile("${path.module}/manifests/internal-load-balance.yaml", 
    {
      hostname = local.workspace.domain,
      certificate_arn = local.workspace.certificate_arn
    })
}

resource "kubectl_manifest" "load_balance_external" {
  depends_on = [module.load_balancer_controller]
  yaml_body  = templatefile("${path.module}/manifests/external-load-balance.yaml", 
    {
      hostname = local.workspace.domain,
      certificate_arn = local.workspace.certificate_arn
      waf_alb_arn = local.wafv2_acl_arn
    })
}