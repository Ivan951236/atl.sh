# atl.sh Admin Guide

## Architecture

atl.sh is a single-server pubnix managed by Ansible.

- **OS**: Debian 13 (Trixie)
- **Provisioning**: Terraform (staging VPS + Cloudflare DNS only; prod is bare-metal)
- **Configuration**: Ansible (5 roles)
- **User Lifecycle**: Ansible playbooks (`create-user.yml`, `remove-user.yml`)

## Prerequisites

- [Ansible](https://docs.ansible.com/)
- [just](https://github.com/casey/just) — run `just` to list all commands
- [Terraform](https://www.terraform.io/) 1.8+
- [Vagrant](https://www.vagrantup.com/) + [vagrant-libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt) (for local dev)

## Deployment

### Initial Setup

```bash
# 1. Install Ansible dependencies
just install
pre-commit install

# 2. Provision staging infrastructure (prod is bare-metal, skip for prod-only setup)
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Fill in secrets, then:
just tf-init && just tf-apply

# 3. Configure the server
just deploy staging   # staging VPS first
just deploy prod      # physical server
```

### Environments

| Target   | Host            | Description                       |
|----------|-----------------|-----------------------------------|
| dev      | 127.0.0.1:2223  | Local Vagrant VM                  |
| staging  | staging.atl.sh  | Hetzner Cloud VPS                 |
| prod     | atl.sh          | Physical Hetzner dedicated server |

### Selective Deployment

```bash
just deploy-tag prod base          # OS baseline + all user packages
just deploy-tag prod infra         # SSH, firewall, fail2ban, AIDE, monitoring, backups
just deploy-tag prod users         # skel, MOTD, PAM limits
just deploy-tag prod environment   # cgroup limits, quotas, tmpfs, PATH
just deploy-tag prod services      # nginx, Gemini, Gopher, finger, FTP, games, webring
```

### User Management

```bash
just create-user johndoe 'ssh-ed25519 AAAA...' prod
just remove-user johndoe prod
```

## Roles

| Role          | Purpose                                                         |
|---------------|-----------------------------------------------------------------|
| `base`        | Apt cache, base packages, NTP, shells, languages, editors, CLI tools |
| `infra`       | SSH hardening, firewall, fail2ban, auditd, AIDE, monitoring, backups |
| `users`       | Skel files, MOTD, PAM limits                                    |
| `environment` | Cgroup limits, disk quotas, tmpfs isolation, XDG dirs, PATH     |
| `services`    | Nginx, Gemini, Gopher, finger, FTP, games, webring              |

## Secrets

All secrets are stored in `ansible/inventory/group_vars/all/vault.yml` and
encrypted with Ansible Vault.

```bash
just vault-edit

# Run playbook with vault password prompt
cd ansible && ansible-playbook site.yml --ask-vault-pass
```

## Logging & Auditing

- **System logs**: `systemd-journald` with a 1 GB cap
- **Service logs**: Nginx and Fail2ban rotated by `logrotate`
- **Security auditing**: `auditd` with 40+ rules covering identity files,
  privilege escalation, suspicious tools, and syscalls (MITRE ATT&CK tagged)
- **File integrity**: AIDE checks daily at 05:00 UTC

```bash
ausearch -ts recent          # recent audit events
ausearch -k priv_esc         # privilege escalation
aureport --summary           # audit summary report
```

## Log Locations

| Log            | Path                         |
|----------------|------------------------------|
| Nginx          | `/var/log/nginx/`            |
| Gemini         | `/var/log/molly-brown/`      |
| Fail2ban       | `/var/log/fail2ban.log`      |
| Audit log      | `/var/log/audit/audit.log`   |
| System journal | `journalctl` (1 GB cap)      |
| Borgmatic      | `journalctl -u borgmatic`    |
