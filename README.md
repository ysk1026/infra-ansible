# infra-ansible

Provisioning and service bootstrap for Hadoop ecosystem.

## Quick start

1. Copy inventory
   - `cp ansible/inventory/hosts.ini.example ansible/inventory/hosts.ini`
2. Edit hosts and credentials
3. Run
   - `make ansible-plan`
   - `make ansible-apply`

## Commands

- `make ansible-plan` dry-run check
- `make ansible-apply` apply all roles
- `make pipeline-demo` run pipeline demo playbook
- `make validate-stack` quick service status checks

## Branch policy

- Default branch: `main`
- Feature branches: `feature/*`
- Merge via PR after review
