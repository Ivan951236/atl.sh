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
- Docker (for local dev)
- Ansible, Terraform

Install Ansible collections and roles:

```bash
just install
```

### Environments

| Target   | Host     | Description                    |
|----------|----------|--------------------------------|
| `dev`    | dev      | Local Docker container         |
| `staging`| staging  | Terraform Hetzner Cloud VPS    |
| `prod`   | prod     | Physical Hetzner server        |

### Local Development Environment

A Docker-based development environment for testing Ansible playbooks locally:

```bash
just dev-up
just deploy dev

# SSH into dev container
ssh -p 2222 -i .ssh/dev_key root@localhost
```

The development container:
- Runs Debian Trixie with systemd
- Uses safe resource limits (4GB RAM, 4 CPUs, 2048 PIDs)
- Mounts Ansible playbooks read-only for testing
- Skips security hardening (sysctl) and quotas (not supported in containers)

## Deployment

### Infrastructure Provisioning

```bash
just tf-init
just tf-apply
```

### Configuration Management

```bash
just deploy dev      # Local Docker
just deploy staging  # Hetzner VPS (set STAGING_HOST or use staging.atl.sh)
just deploy prod     # Physical server (set PROD_HOST or use atl.sh)

# Specific roles
just deploy-tag staging common,packages,users
```

### Quality Control

```bash
pre-commit install
just lint
```

## Documentation

- [User Guide](docs/user-guide.md)
- [Admin Guide](docs/admin-guide.md)
- [Architecture](docs/architecture.md)
- [Testing Guide](docs/testing.md)
