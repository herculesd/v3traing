resource "helm_release" "rancher_backup_crd" {
  count      = local.workspace.rancher_backup.enable ? 1 : 0
  name       = "rancher-backup-crd"
  repository = "https://charts.rancher.io"
  chart      = "rancher-backup-crd"
  version    = "2.0.1"
  namespace  = "cattle-resources-system"
  create_namespace = true
}

resource "helm_release" "rancher_backup" {
  depends_on = [helm_release.rancher_backup_crd]  
  count      = local.workspace.rancher_backup.enable ? 1 : 0
  name       = "rancher-backup"
  repository = "https://charts.rancher.io"
  chart      = "rancher-backup"
  version    = "2.0.1"
  namespace  = "cattle-resources-system"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.rancher[0].arn
  }
}

resource "aws_kms_key" "rancher_s3" {
  count      = local.workspace.rancher_backup.enable ? 1 : 0
  description             = "This key is used to encrypt rancher backup in s3"
}

resource "aws_s3_bucket" "rancher" {
  depends_on = [helm_release.rancher_backup_crd]  
  count      = local.workspace.rancher_backup.enable ? 1 : 0    
  bucket = local.workspace.rancher_backup.bucket_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.rancher_s3[0].arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Backup      = true
    Name        = local.workspace.rancher_backup.bucket_name
    Environment = local.workspace.environment_name
  }
}

resource "kubectl_manifest" "backup_definition" {
  depends_on = [helm_release.rancher_backup] 
  count = local.workspace.rancher_backup.enable ?  local.workspace.rancher_backup.scheduler_enable ? length(local.workspace.rancher_backup.backup_namespaces) : 0 : 0
  yaml_body = templatefile("${path.module}/backup/backup-definition.yaml", {
  namespace = local.workspace.rancher_backup.backup_namespaces[count.index]
  })
}

resource "kubectl_manifest" "backup_scheduler" {
  depends_on = [kubectl_manifest.backup_definition]  
  count = local.workspace.rancher_backup.enable ?  local.workspace.rancher_backup.scheduler_enable ? length(local.workspace.rancher_backup.backup_namespaces) : 0 : 0
  yaml_body = templatefile("${path.module}/backup/backup-scheduler.yaml", {
  namespace = local.workspace.rancher_backup.backup_namespaces[count.index],
  scheduler = local.workspace.rancher_backup.scheduler,
  retention = local.workspace.rancher_backup.retention,
  bucket_name = local.workspace.rancher_backup.bucket_name,
  region = local.workspace.rancher_backup.region
  })
}
