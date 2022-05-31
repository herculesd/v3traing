data "template_file" "launch_template_userdata" {
  template = file("${path.module}/templates/userdata.sh.tpl")

  vars = {
    cluster_name        = local.workspace.eks.name
    endpoint            = element(concat(data.aws_eks_cluster.cluster[*].endpoint, [""]), 0)
    cluster_auth_base64 = element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, [""]), 0)

    bootstrap_extra_args = ""
    kubelet_extra_args   = ""
  }
}

resource "aws_kms_key" "eks_kms_key" {
  count = local.workspace.eks.enabled ? 1 : 0

  description             = "KMS key EKS"
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.ebs_decryption[0].json
}

# This is based on the LT that EKS would create if no custom one is specified (aws ec2 describe-launch-template-versions --launch-template-id xxx)
# there are several more options one could set but you probably dont need to modify them
# you can take the default and add your custom AMI and/or custom tags
#
# Trivia: AWS transparently creates a copy of your LaunchTemplate and actually uses that copy then for the node group. If you DONT use a custom AMI,
# then the default user-data for bootstrapping a cluster is merged in the copy.
resource "aws_launch_template" "default" {
  count = local.workspace.eks.enabled ? 1 : 0

  name_prefix            = "eks-launch-template-${local.workspace.eks.launch_template.name}"
  description            = "Default Launch-Template ${local.workspace.eks.launch_template.name}"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = local.workspace.eks.launch_template.volume_size
      volume_type           = local.workspace.eks.launch_template.volume_type
      delete_on_termination = local.workspace.eks.launch_template.delete_on_termination
      encrypted             = true
      kms_key_id            = aws_kms_key.eks_kms_key[0].arn
    }
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [module.eks_cluster[0].worker_security_group_id]
  }

  # if you want to use a custom AMI
  # image_id      = var.ami_id

  # If you use a custom AMI, you need to supply via user-data, the bootstrap script as EKS DOESNT merge its managed user-data then
  # you can add more than the minimum code you see in the template, e.g. install SSM agent, see https://github.com/aws/containers-roadmap/issues/593#issuecomment-577181345
  #
  # (optionally you can use https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/cloudinit_config to render the script, example: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/997#issuecomment-705286151)

  # user_data = base64encode(
  #   data.template_file.launch_template_userdata.rendered,
  # )


  # Supplying custom tags to EKS instances is another use-case for LaunchTemplates
  tag_specifications {
    resource_type = "spot-instances-request"

    tags = {
      CustomTag = "EKS launch-template ${local.workspace.eks.launch_template.name}"
    }
  }

  # Supplying custom tags to EKS instances root volumes is another use-case for LaunchTemplates. (doesnt add tags to dynamically provisioned volumes via PVC tho)
  tag_specifications {
    resource_type = "volume"

    tags = {
      CustomTag = "EKS launch-template ${local.workspace.eks.launch_template.name}"
    }
  }

  # Tag the LT itself
  tags = {
    CustomTag = "EKS launch-template ${local.workspace.eks.launch_template.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
