# Makefile

DOMAIN = citycloud.23technologies.xyz
ENDPOINT = citycloud.designate-in-a-box.23technologies.xyz

ENVIRONMENT ?= default
USERNAME = dragon

OPENSTACK = openstack
TERRAFORM = terraform

PARALLELISM = 10

RESOURCE = openstack_networking_floatingip_v2.floating_ip

APPLY_PARAMS = -auto-approve -parallelism=$(PARALLELISM)

export OS_CLOUD ?= $(ENVIRONMENT)
export TF_VAR_cloud_provider=$(ENVIRONMENT)

reset:
	@rm -rf .terraform terraform.tfstate.d .terraform.lock.hcl

init:
	@if [ ! -d .terraform/providers ]; then $(TERRAFORM) init; fi

	@$(TERRAFORM) workspace select ${ENVIRONMENT} || $(TERRAFORM) workspace new ${ENVIRONMENT}

	@rm -f *_override.tf
	@for over in `grep '^# *override:' "environments/${ENVIRONMENT}.tfvars" | sed 's/^# *override://'`; do \
	  cp -p overrides/$${over}_override.tf .; \
	done

	@rm -f *_custom.tf
	@for custom in `grep '^# *customisation:' "environments/${ENVIRONMENT}.tfvars" | sed 's/^# *customisation://'`; do \
	  cp -p customisations/$${custom}_custom.tf .; \
	done

validate: init
	@$(TERRAFORM) validate $(PARAMS)

attach: init
	@$(TERRAFORM) import -var-file="environments/$(ENVIRONMENT).tfvars" $(RESOURCE) $(PARAMS)

detach: init
	@$(TERRAFORM) state rm $(RESOURCE) $(PARAMS)

plan: init
	@$(TERRAFORM) plan -var-file="environments/$(ENVIRONMENT).tfvars" $(PARAMS)

deploy: init
	@touch .deploy.$(ENVIRONMENT)
	@$(TERRAFORM) apply $(APPLY_PARAMS) -var-file="environments/$(ENVIRONMENT).tfvars" -var "domain=$(DOMAIN)" -var "endpoint=$(ENDPOINT)" $(PARAMS)

openstack: init
	@$(OPENSTACK)

graph: init
	@$(TERRAFORM) graph

show: init
	@$(TERRAFORM) show

list: init
	@$(TERRAFORM) state list

ssh: .ADDRESS.$(ENVIRONMENT) .id_rsa.$(ENVIRONMENT)
	@. ./.ADDRESS.$(ENVIRONMENT); \
	ssh -o StrictHostKeyChecking=no -i .id_rsa.$(ENVIRONMENT) $(USERNAME)@$$ADDRESS

sshuttle: .ADDRESS.$(ENVIRONMENT) .id_rsa.$(ENVIRONMENT)
	@. ./.ADDRESS.$(ENVIRONMENT); \
	sshuttle --ssh-cmd "ssh -o StrictHostKeyChecking=no -i .id_rsa.$(ENVIRONMENT) " -r $(USERNAME)@$$ADDRESS 192.168.16.0/20

console: .deploy.$(ENVIRONMENT)
	@$(OPENSTACK) console url show designate-in-a-box

log: .deploy.$(ENVIRONMENT)
	@$(OPENSTACK) console log show designate-in-a-box

clean: init
	@$(TERRAFORM) destroy $(APPLY_PARAMS) -var-file="environments/$(ENVIRONMENT).tfvars" $(PARAMS)
	@rm -f .deploy.$(ENVIRONMENT) .ADDRESS.$(ENVIRONMENT)
	@rm -f .id_rsa.$(ENVIRONMENT)
	@$(TERRAFORM) workspace select default
	@$(TERRAFORM) workspace delete $(ENVIRONMENT)
	@rm -f *_override.tf

create: deploy
login: ssh
tunnel: sshuttle

PHONY: init validate deploy openstack graph show list ssh plan clean
