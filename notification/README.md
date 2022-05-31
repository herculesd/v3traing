# Notification Terraform Stack

This stack manages the creation of network, ECS and EKS cluster and more.

## Configuration Variables

All configuration is loaded from the file `one.yaml` by the file `_settings.tf`.

Variables can change per workspace, to access a variable in your .tf file, set at `one.yaml` under all workspaces and use: `local.workspace.my_variable`

Variables that are common to all workspaces can be set at `_settings.tf`.

## Resources

- ACM
- Route53
- VPC
- OpenVPN
- ECR
- IAM Roles

## Workspaces

- shared-services-us-east-2-default
- prod-us-east-2-default
- nonprod-us-east-2-dev

## Deploying

### 1. Export Workspace

1. audit:           `export WORKSPACE=audit-us-east-2-default`
2. prod:            `export WORKSPACE=prod-us-east-2-default`
3. nonprod:         `export WORKSPACE=nonprod-us-east-2-dev`

### 2. Google/Azure SSO Authentication
```
make google-auth
# or
make azure-auth
```

### 3. terraform init
```
make init
```

### 4. terraform plan
```
make plan
```

### 5. terraform apply
```
make apply
```

### Other operations supported
Enter a shell with AWS credentials and terraform:
```
make shell

# common commands to run inside the shell:

# check your AWS creds by running:
aws sts get-caller-identity

# list terraform state with:
terraform state list

# import a terraform resource:
terraform import aws_guardduty_detector.member[0] 00b00fd5aecc0ab60a708659477e0627
```