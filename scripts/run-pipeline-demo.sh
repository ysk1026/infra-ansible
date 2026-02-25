#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
ANSIBLE_DIR="${INFRA_DIR}/ansible"

INVENTORY="${ANSIBLE_INVENTORY:-${ANSIBLE_DIR}/inventory/hosts.ini}"
PLAYBOOK="${ANSIBLE_PIPELINE_PLAYBOOK:-${ANSIBLE_DIR}/playbooks/pipeline_demo.yml}"
export ANSIBLE_CONFIG="${ANSIBLE_CONFIG:-${ANSIBLE_DIR}/ansible.cfg}"

ansible-playbook -i "${INVENTORY}" "${PLAYBOOK}" "$@"
