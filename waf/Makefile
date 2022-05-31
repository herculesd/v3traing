export AZURE_TENANT_ID?=e5e9d8fd-e8df-4107-8326-0c228996f7d3
export AZURE_APP_ID_URI?=6a6e00d9-0f77-4cf2-9c68-51c0a4baca11
export AZURE_DEFAULT_DURATION_HOURS=1
export AWS_DEFAULT_REGION=us-east-1

GOOGLE_AUTH_IMAGE=public.ecr.aws/dnxsolutions/aws-google-auth:latest
AZURE_AUTH_IMAGE=public.ecr.aws/dnxsolutions/docker-aws-azure-ad:latest
AWS_IMAGE=public.ecr.aws/dnxsolutions/aws-v2:2.2.9-dnx1
TERRAFORM_IMAGE=public.ecr.aws/dnxsolutions/terraform:1.0.0-dnx1

RUN_GOOGLE_AUTH=docker run -it --rm --env-file=.env -v $(PWD)/.env.auth:/work/.env $(GOOGLE_AUTH_IMAGE)
RUN_AZURE_AUTH =docker run -it --rm --env-file=.env -v $(PWD)/.env.auth:/work/.env $(AZURE_AUTH_IMAGE)
RUN_AWS        =docker run -i --rm --env-file=.env.auth --env-file=.env -v $(PWD):/work -v $(PWD)/aws-sso-config:/root/.aws/config --entrypoint "" $(AWS_IMAGE)
RUN_TERRAFORM  =docker run -i --rm --env-file=.env.auth --env-file=.env -v $(PWD):/work -v /var/run/secrets:/var/run/secrets $(TERRAFORM_IMAGE)

OIDC_REQUIRED=
ifdef BITBUCKET_STEP_OIDC_TOKEN
	OIDC_REQUIRED=.oidc.token
	export OIDC_AWS_ACCOUNT_ID?=<SHARED_SERVICES_ACCOUNT_ID>
	export OIDC_AWS_ROLE?=InfraDeployBitbucket
	export OIDC_TOKEN=$(BITBUCKET_STEP_OIDC_TOKEN)
	export AWS_WEB_IDENTITY_TOKEN_FILE=/work/.oidc.token
	export AWS_ROLE_ARN=arn:aws:iam::$(OIDC_AWS_ACCOUNT_ID):role/$(OIDC_AWS_ROLE)
endif

env-%: # Check for specific environment variables
	@ if [ "${${*}}" = "" ]; then echo "Environment variable $* not set"; exit 1;fi

.env:
	cp .env.template .env
	echo >> .env
	touch .env.auth

.oidc.token: env-OIDC_TOKEN
	echo $(OIDC_TOKEN) > $(PWD)/.oidc.token

clean-dotenv:
	-rm .env

google-auth: .env env-GOOGLE_IDP_ID env-GOOGLE_SP_ID
	echo > .env.auth
	$(RUN_GOOGLE_AUTH)

azure-auth: .env env-AZURE_TENANT_ID env-AZURE_APP_ID_URI
	echo > .env.auth
	$(RUN_AZURE_AUTH)

init: .env env-WORKSPACE $(OIDC_REQUIRED)
	$(RUN_TERRAFORM) init
	$(RUN_TERRAFORM) workspace new $(WORKSPACE) 2>/dev/null; true # ignore if workspace already exists
	$(RUN_TERRAFORM) workspace "select" $(WORKSPACE)
.PHONY: init

lint: .env
	$(RUN_TERRAFORM) fmt --recursive -check=true
.PHONY: lint

validate: .env
	$(RUN_TERRAFORM) validate
.PHONY: validate

shell: .env
	docker run -it --rm --env-file=.env.auth --env-file=.env -v $(PWD):/work --entrypoint "/bin/bash" $(TERRAFORM_IMAGE)
.PHONY: shell

apply: .env env-WORKSPACE
	$(RUN_TERRAFORM) apply .terraform-plan-$(WORKSPACE)
.PHONY: apply

plan: .env env-WORKSPACE
	$(RUN_TERRAFORM) plan -out=.terraform-plan-$(WORKSPACE)
.PHONY: plan

check_clean:
	@echo "Are you sure you want to delete the files? It's including (terraform files, gsuite xml and git repository) [yes/no] " && read ans && [ $${ans:-N} == yes ]
.PHONY: clean check_clean

clean: check_clean .env
	echo "+++ :system: Cleaning default files"
	rm -rf .terraform terraform.tfstate* terraform.tfstate.d .git ||:

output:
	@$(RUN_TERRAFORM) output -json > output.json
.PHONY: output

aws-sso-configure:
	$(RUN_AWS) aws configure sso
.PHONY: aws-sso-configure

aws-sso-auth: .env env-AWS_SSO_PROFILE
	$(RUN_AWS) bash /opt/scripts/aws-sso.sh > .env.auth
.PHONY: aws-sso-auth