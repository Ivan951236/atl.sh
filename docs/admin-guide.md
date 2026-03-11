# atl.sh Admin Guide

## Architecture

atl.sh is a single-server pubnix managed by Ansible.

- **OS**: Debian 13 (Trixie)
- **Provisioning**: Terraform (Hetzner Cloud + Cloudflare DNS)
- **Configuration**: Ansible (9 roles)
- **User Lifecycle**: Portal integration via Ansible playbooks

## Deployment

This project uses [just](https://github.com/casey/just). Run `just` to list commands.

### Initial Setup

```bash
# 1. Provision infrastructure (staging VPS)
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Fill in secrets
just tf-init && just tf-apply

# 2. Install dependencies and hooks
just install
pre-commit install

# 3. Configure the server
just deploy staging   # or: deploy prod for physical server
```

### Environments

| Target   | Ansible host   | Host (env override)              |
|----------|----------------|----------------------------------|
| dev      | atl-sh-dev     | 127.0.0.1:2223                   |
| staging  | atl-sh-staging | staging.atl.sh (ATL_HOST=atl.sh) |
| prod     | atl-sh-prod    | atl.sh (ATL_HOST)                |

### User Management

```bash
# Create user (target: staging or prod)
just create-user johndoe 'ssh-ed25519 AAAA...' staging

# Remove user
just remove-user johndoe prod
```

### Selective Runs

```bash
just deploy-tag staging security     # SSH, Firewall on staging
just deploy-tag prod services        # Web, Gemini, Gopher on prod
just deploy-tag prod environment     # systemd limits, tmpfs
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

## Logging & Auditing

The system uses a hybrid approach to maintain performance and visibility:

- **System Logs**: Managed by `systemd-journald` with a 1GB cap.
- **Service Logs**: High-volume services (Nginx, Fail2ban) are rotated by `logrotate` with best practices (compression, date suffixes).
- **Security Auditing**: `auditd` is configured with robust rules for monitoring system calls, file integrity, and potential "Living Off The Land" (LOTL) activities.
- **User Logs**: A system-wide cron job runs `logrotate` for users who opt-in via `~/.logrotate.conf`.

## Secrets

All secrets are stored in `ansible/inventory/group_vars/all/vault.yml` and encrypted with Ansible Vault.

```bash
just vault-edit

# Run playbook with vault
cd ansible && ansible-playbook site.yml --ask-vault-pass
```
