# Audit Terraform Stack


## Configuration Variables

All configuration is loaded from the file `one.yaml` by the file `_settings.tf`.

Variables can change per workspace, to access a variable in your .tf file, set at `one.yaml` under all workspaces and use: `local.workspace.my_variable`

Variables that are common to all workspaces can be set at `_settings.tf`.

## Resources

- AWS Config
- Security Hub
- GuardDuty
- CloudTrail
- IAM Roles

## Workspaces

- audit-us-east-2-default

## Deploying

### 1. Export Workspace

1. audit (us): `export WORKSPACE=audit-us-east-2-default`

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
terraform import aws_guardduty_detector.member[0] 00b00fd5aecc0ab60a708659477e9617
```