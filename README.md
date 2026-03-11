# atl.sh

Public UNIX environment for the All Things Linux community.

atl.sh is a shared system providing shell access, web hosting, and alternative protocol services (Gemini, Gopher) for community members.

## Features

- **Shell Access**: SSH environment with standard CLI tools (Vim, Neovim, Tmux, Git).
- **Web Hosting**: Static hosting at `https://atl.sh/~username` via Nginx.
- **Alternative Protocols**: Project hosting via Gemini (`gemini://atl.sh/~username`) and Gopher (`gopher://atl.sh/~username`).
- **Development**: Toolchains available for C, C++, Python, Node.js, Go, Rust, Ruby and more.
- **Isolation**: Resource management and user isolation using Cgroups v2 and systemd-slices.

## Tech Stack

| Component | Technology |
| :--- | :--- |
| OS | Debian 13 (Trixie) |
| Configuration | Ansible |
| Infrastructure | Terraform (Hetzner, Cloudflare) |
| Web Server | Nginx |
| Gemini / Gopher | molly-brown, Gophernicus |
| FTP | vsftpd |
| Backups | Borgmatic |
| Monitoring | prometheus-node-exporter, smartmontools |
| Logging | logrotate, journald |
| Security | UFW, Fail2ban, Auditd, user slices |

## Security and Isolation

The system implements multiple layers of protection to ensure stability for all users:

- **CIS Hardening**: Implements CIS Level 2 benchmark controls including kernel hardening (ASLR, ptrace restrictions), network protections (SYN cookies, anti-spoofing), and module blacklisting.
- **Resource Limits**: systemd user slices enforce kernel-level caps on CPU, memory, and process count per user.
- **Hardened /tmp**: User-specific temporary directories are mounted as `tmpfs` with `nodev`, `nosuid`, and `noexec` options.
- **Quotas**: User and group filesystem quotas are enforced on the root partition.
- **Network**: SSH is rate-limited and protected by Fail2ban with strong cryptographic ciphers.
- **Monitoring**: AIDE file integrity monitoring, enhanced auditd logging, and automatic security updates.

## Development

This project uses [just](https://github.com/casey/just) for common tasks. Run `just` to list commands.

### Prerequisites

- [just](https://github.com/casey/just) — command runner
- [Vagrant](https://www.vagrantup.com/) + [vagrant-libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt) (KVM) for local dev — see [Testing Guide](docs/testing.md#setup) for libvirt and Vagrant installation
- Ansible
- Terraform 1.8+ (Cloudflare provider v5)

Install Ansible collections and roles:

```bash
just install
```

### Environments

| Target   | Host          | Description                    |
|----------|---------------|--------------------------------|
| `dev`    | atl-sh-dev    | Local Vagrant VM               |
| `staging`| atl-sh-staging| Terraform Hetzner Cloud VPS    |
| `prod`   | atl-sh-prod   | Physical Hetzner server        |

### Local Development Environment

A Vagrant VM for testing Ansible playbooks locally. Requires `.ssh/dev_key` and `.ssh/dev_key.pub` (create with `ssh-keygen -f .ssh/dev_key -t ed25519 -N ""`). See [docs/testing.md](docs/testing.md) for full setup and troubleshooting.

```bash
just dev-up
just deploy dev

# SSH into dev VM (port 2223; see docs/testing.md for vagrant-libvirt notes)
ssh -p 2223 -i .ssh/dev_key root@127.0.0.1
```

The development VM:
- Runs Debian Trixie with native systemd
- Uses 4GB RAM, 4 CPUs
- Runs full playbook including security and quotas (Vagrant VM matches staging/prod)

## Deployment

### Infrastructure Provisioning

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with Hetzner and Cloudflare credentials

just tf-init
just tf-apply
```

### Configuration Management

```bash
just deploy dev      # Local Vagrant VM
just deploy staging  # Hetzner VPS → staging.atl.sh (set ATL_HOST to override)
just deploy prod     # Physical server → atl.sh (set ATL_HOST to override)

# Specific roles
just deploy-tag staging common,packages,users
```

### User Management

```bash
just create-user <username> '<ssh-ed25519 AAAA...>' staging   # or prod
just remove-user <username> staging
```

See [Admin Guide](docs/admin-guide.md) for details.

### Quality Control

```bash
pre-commit install
just lint
```

## Documentation

- [User Guide](docs/user-guide.md) — Getting started on atl.sh
- [Admin Guide](docs/admin-guide.md) — Server administration
- [FAQ](docs/faq.md)
- [Testing Guide](docs/testing.md)
- [Code of Conduct](docs/code-of-conduct.md)
