terraform {
  backend "s3" {
    bucket  = "v3training-terraform-backend"
    key     = "app-platform-eks"
    region  = "us-east-2"
    encrypt = true
    role_arn = "arn:aws:iam::955364924205:role/InfraDeployAccess" # shared-services role
  }
}