# EKS Platform Terraform Stack

This stack manages EKS Cluster and Node Groups setup.

## Configuration Variables

All configuration is loaded from the file `one.yaml` by the file `_settings.tf`.

Variables can change per workspace, to access a variable in your .tf file, set at `one.yaml` under all workspaces and use: `local.workspace.my_variable`

Variables that are common to all workspaces can be set at `_settings.tf`.

## Resources

- EKS Cluster

## Workspaces

- nonprod-us-east-2-dev
- prod-us-east-2-default

## Deploying

### 1. Export Workspace

1. nonprod:         `export WORKSPACE=nonprod-us-east-2-dev`
2. prod:            `export WORKSPACE=prod-us-east-2-default`

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

## Operations

### kube-shell

Set the variables according to the cluster you want to connect (check one.yaml for the name and ID):

```bash
export CLUSTER_NAME=dev-apps
export AWS_ACCOUNT_ID=015312168739
export AWS_ROLE=cargueroDNXAccess
```

Open kube-shell with:
```bash
make kube-shell

# test connectivity:
kubectl get nodes
```
