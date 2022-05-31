resource "helm_release" "rancher" {
  count      = local.workspace.rancher.enable ? 1 : 0
  name             = "rancher"
  chart            = "rancher"
  repository       = "https://releases.rancher.com/server-charts/latest"
  namespace        = "cattle-system"
  create_namespace = true

  version          = local.workspace.rancher.version

  set {
    name = "replicas"
    value = local.workspace.rancher.replicas
  }

  set {
    name  = "hostname"
    value = local.workspace.rancher.hostname  
  }

  set {
    name = "ingress.provider"
    value = "none"
  }

  set {
    name = "ingress.enabled"
    value = "false"
  }  

  set {
    name = "tls"
    value = "external"
  }  
}

resource "kubectl_manifest" "rancher" {
  count      = local.workspace.rancher.enable ? 1 : 0
  depends_on = [helm_release.rancher,module.load_balancer_controller]
  yaml_body  = templatefile("${path.module}/manifests/rancher-ingress.yaml", {
    hostname = local.workspace.rancher.hostname,
    domain = local.workspace.domain,
    group_name = "${local.workspace.rancher.load_balance_type == "internal" ? "internal" : "internet-facing"}",
    schema = "${local.workspace.rancher.load_balance_type == "internal" ? "internal" : "internet-facing"}"})
}
