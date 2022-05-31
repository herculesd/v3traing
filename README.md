# AWS Well-Architected Foundations - DNX ONE

## Documentation (_docs folder)

This folder [_docs](_docs/README.md) contains a README.md file with the documentation for this Foundation.

## CloudFormation Templates (_cf-templates folder)

Here we store CloudFormation templates that are used in this Foundation.

**all-accounts/identity-baseline.cf.yml**

This is a required stack to be deployed to all accounts part of this Foundation (except the master account).
Contains service roles that allows this Foundation to run.
Allow access to DNX as a parameter that can be enabled or disabled.

**shared-services/terraform-backend.cf.yml**

This stack goes into to the Shared-Services account. 
Creates S3 bucket for Terraform to store state files.

**_optional/master/identity-billing-access.cf.yml**

This stack creates a IAM Role that allows DNX to access billing in this account.

It's possible to activate Budget Alarms that creates a budget alarm to the email specified. It's a forecasted alarm, which means it will alert based on the month trend to pass the budget. Also is possible to enable the Cost Anomaly that will alert if the cost is predicted to be greater than the threshold defined.

## Stacks

The correct order execution is as below.

- [audit](audit/README.md)
- [baseline](baseline/README.md)
- [identity](identity/README.md)
- [platform](platform/README.md)
- [waf](waf/README.md)
- [app-platform-eks](app-platform-eks/README.md)
- [eks-postinstall](eks-postinstall/README.md)
