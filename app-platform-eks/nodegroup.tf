locals { 

  node_groups_config = {
    nonprod = {
      nodes = {
        desired_capacity = local.workspace.eks.node_group.desired_capacity
        max_capacity     = local.workspace.eks.node_group.max_capacity
        min_capacity     = local.workspace.eks.node_group.min_capacity
        instance_types   = local.workspace.eks.node_group.instance_types
        capacity_type    = "SPOT"
        launch_template_id      = aws_launch_template.default[0].id
        launch_template_version = aws_launch_template.default[0].default_version
        k8s_labels = {
          Environment = local.workspace.eks.node_group.name
        }
        additional_tags = {
          CustomTag = "EKS ${local.workspace.eks.name}"
        }
      }
    },

    prod = {
      nodes = {
        desired_capacity = local.workspace.eks.node_group.desired_capacity
        max_capacity     = local.workspace.eks.node_group.max_capacity
        min_capacity     = local.workspace.eks.node_group.min_capacity
        instance_types   = local.workspace.eks.node_group.instance_types
        capacity_type    = "SPOT"
        launch_template_id      = aws_launch_template.default[0].id
        launch_template_version = aws_launch_template.default[0].default_version
        k8s_labels = {
          Environment = local.workspace.eks.node_group.name
        }
        additional_tags = {
          CustomTag = "EKS ${local.workspace.eks.name}"
        }
      }
    }
  }
}