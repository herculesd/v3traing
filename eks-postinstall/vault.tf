resource "helm_release" "vault" {
  count      = local.workspace.vault.enable ? 1 : 0
  name             = "vault"
  chart            = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  namespace        = "vault"
  create_namespace = true
  version          = local.workspace.vault.version_chart
  values = [
    templatefile("${path.module}/helm_values/vault.yaml", {
      kms_key_id  = aws_kms_key.secret_key.key_id,
      region      = local.workspace.aws_region
      hostname = local.workspace.vault.hostname })
  ]

  set {
    name  = "server.ha.enabled"
    value = true
  }

  set {
    name  = "server.ha.replicas"
    value = local.workspace.vault.replicas
  }


  set {
    name  = "server.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.secret.arn
  }

}


  resource "kubectl_manifest" "vault_ingress" {
  count      = local.workspace.vault.enable ? 1 : 0
  depends_on = [helm_release.vault]
  yaml_body  = templatefile("${path.module}/manifests/vault-ingress.yaml", 
   {
       hostname = local.workspace.vault.name,
       domain = local.workspace.domain,
       group_name = "${local.workspace.vault.load_balance_type == "internal" ? "internal" : "internet-facing"}",
       schema = "${local.workspace.vault.load_balance_type == "internal" ? "internal" : "internet-facing"}"})
}