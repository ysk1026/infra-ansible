SHELL := /bin/bash

ANSIBLE_DIR := $(CURDIR)/ansible
SCRIPTS_DIR := $(CURDIR)/scripts

.PHONY: ansible-plan ansible-apply ansible-check pipeline-demo validate-stack

ansible-plan:
	$(SCRIPTS_DIR)/run-ansible.sh --check

ansible-apply:
	$(SCRIPTS_DIR)/run-ansible.sh

ansible-check:
	ansible-playbook -i $(ANSIBLE_DIR)/inventory/hosts.ini $(ANSIBLE_DIR)/site.yml --syntax-check

pipeline-demo:
	$(SCRIPTS_DIR)/run-pipeline-demo.sh

validate-stack:
	$(SCRIPTS_DIR)/validate-stack.sh
