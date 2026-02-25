#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
ANSIBLE_DIR="${INFRA_DIR}/ansible"

INVENTORY="${ANSIBLE_INVENTORY:-${ANSIBLE_DIR}/inventory/hosts.ini}"
export ANSIBLE_CONFIG="${ANSIBLE_CONFIG:-${ANSIBLE_DIR}/ansible.cfg}"

ansible -i "${INVENTORY}" hadoop -b -m shell -a "systemctl is-active hadoop-namenode hadoop-resourcemanager hadoop-datanode hadoop-nodemanager || true"
ansible -i "${INVENTORY}" hadoop_edge -b -m shell -a "systemctl is-active hive-metastore hive-server2 spark-history-server kafka-zookeeper kafka-broker || true"
