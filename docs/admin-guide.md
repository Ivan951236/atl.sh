# atl.sh Admin Guide

## Architecture

atl.sh is a single-server pubnix managed by Ansible.

- **OS**: Debian 13 (Trixie)
- **Provisioning**: Terraform (Hetzner Cloud + Cloudflare DNS)
- **Configuration**: Ansible (9 roles)
- **User Lifecycle**: Portal integration via Ansible playbooks

## Deployment

### Initial Setup

```bash
# 1. Provision infrastructure
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Fill in secrets
terraform init && terraform apply

# 2. Install dependencies and hooks
cd ..
ansible-galaxy install -r requirements.yml
pre-commit install

# 3. Configure the server
cd ansible
ansible-playbook site.yml
```

### User Management

```bash
# Create user (triggered by portal)
ansible-playbook playbooks/create-user.yml \
  -e "username=johndoe" \
  -e "ssh_public_key='ssh-ed25519 AAAA...'"

# Remove user (triggered by portal)
ansible-playbook playbooks/remove-user.yml \
  -e "username=johndoe"
```

### Selective Runs

```bash
# Only update security (SSH, Firewall)
ansible-playbook site.yml --tags security

# Only update user-facing services (Web, Gemini, Gopher)
ansible-playbook site.yml --tags services

# Update environment hardening (systemd limits, tmpfs)
ansible-playbook site.yml --tags environment
```

## Roles

| Role        | Purpose                                      |
|-------------|----------------------------------------------|
| common      | Base system, NTP, sysctl                     |
| packages    | User-facing tools and language runtimes      |
| security    | SSH hardening, fail2ban, UFW firewall        |
| users       | Skel, MOTD, and user-specific config         |
| environment | Global limits, quotas, pathing, tmpfs        |
| services    | Nginx, Gemini (gmid), Gopher (Gophernicus)   |
| monitoring  | Prometheus Node Exporter                     |
| backup      | Borgmatic backups                            |

## Secrets

All secrets are stored in `ansible/inventory/group_vars/all/vault.yml` and encrypted with Ansible Vault.

```bash
# Edit vault
ansible-vault edit ansible/inventory/group_vars/all/vault.yml

# Run playbook with vault
ansible-playbook site.yml --ask-vault-pass
```
