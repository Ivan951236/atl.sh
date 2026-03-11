# atl.sh

> [!NOTE]
> **This project is under heavy development.** Specifics and features are subject to change.

> Public UNIX environment for the [All Things Linux](https://allthingslinux.org) community — shell access, web hosting, Gemini, Gopher, and FTP.

atl.sh is a **pubnix** (public-access Unix server) providing shared shell accounts with static web hosting, alternative protocol support (Gemini, Gopher), and FTP over TLS. Built for learning, sharing, and community.

---

## Quick Links

| For users | For admins |
|-----------|------------|
| [Get an account](https://portal.allthingslinux.org) | [Admin Guide](docs/admin-guide.md) |
| [User Guide](docs/user-guide.md) | [Testing Guide](docs/testing.md) |
| [FAQ](docs/faq.md) | [Code of Conduct](docs/code-of-conduct.md) |

---

## Features

- **Shell Access**: SSH with bash, zsh, fish — standard CLI tools (Vim, Neovim, Tmux, Git).
- **Web Hosting**: Static sites at `https://atl.sh/~username` via Nginx.
- **Alternative Protocols**: Gemini (`gemini://atl.sh/~username`) and Gopher (`gopher://atl.sh/~username`).
- **FTP/S**: Explicit FTP over TLS for file uploads; home directory as root.
- **Development Toolchains**: C, C++, Python, Node.js, Go, Rust, Ruby and more; install to `~/.local/` via pip, npm, cargo, etc.
- **Resource Isolation**: Cgroups v2 and systemd user slices cap CPU, memory, and process count per user.

### Resource Limits (per user)

| Resource | Limit |
|----------|-------|
| Disk | 5 GB soft / 6 GB hard |
| RAM | 1.5 GB |
| CPU | 200% (2 cores) |
| Processes | 200 |

---

## Tech Stack

| Component | Technology |
| :--- | :--- |
| OS | Debian 13 (Trixie) |
| Configuration | Ansible |
| Infrastructure | Terraform (Hetzner Cloud, Cloudflare) |
| Web Server | Nginx |
| Gemini / Gopher | molly-brown, Gophernicus |
| FTP | vsftpd |
| Backups | Borgmatic |
| Monitoring | Prometheus Node Exporter, smartmontools |
| Logging | logrotate, journald |
| Security | UFW, Fail2ban, Auditd, CIS hardening, user slices |

---

## Security and Isolation

The system implements multiple layers of protection:

- **CIS Hardening**: Level 2 benchmark controls — kernel hardening (ASLR, ptrace restrictions), network protections (SYN cookies, anti-spoofing), module blacklisting.
- **Resource Limits**: systemd user slices cap CPU, memory, and process count per user.
- **Hardened /tmp**: User-specific tmpfs with `nodev`, `nosuid`, `noexec`.
- **Quotas**: User and group filesystem quotas on the root partition.
- **Network**: SSH key-only auth, rate limiting, Fail2ban, strong ciphers.
- **Monitoring**: AIDE, enhanced auditd, automatic security updates.

---

## Community

- **IRC**: `#support` on `irc.atl.chat` (port 6697, SSL)
- **Web**: [allthingslinux.org](https://allthingslinux.org)
- **Account signup**: [ATL Portal](https://portal.allthingslinux.org)

---

## Development (Contributors & Admins)

This project uses [just](https://github.com/casey/just) for common tasks. Run `just` to list commands.

### Prerequisites

- [just](https://github.com/casey/just)
- [Vagrant](https://www.vagrantup.com/) + [vagrant-libvirt](https://github.com/vagrant-libvirt) (KVM) for local dev — see [Testing Guide](docs/testing.md#setup)
- Ansible
- Terraform 1.8+ (Cloudflare provider v5)

```bash
just install
```

### Environments

| Target | Host | Description |
|--------|------|-------------|
| `dev` | atl-sh-dev | Local Vagrant VM (port 2223) |
| `staging` | atl-sh-staging | Terraform Hetzner Cloud VPS |
| `prod` | atl-sh-prod | Physical Hetzner server |

### Local Development

```bash
just dev-up
just deploy dev

# SSH into dev VM
ssh -p 2223 -i .ssh/dev_key root@127.0.0.1
```

Requires `.ssh/dev_key` and `.ssh/dev_key.pub` — see [docs/testing.md](docs/testing.md) for setup.

---

## Deployment

### Infrastructure (Terraform)

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit with Hetzner and Cloudflare credentials

just tf-init
just tf-apply
```

### Configuration (Ansible)

```bash
just deploy dev      # Local Vagrant VM
just deploy staging  # Staging VPS
just deploy prod     # Production

# Selective roles
just deploy-tag staging common,packages,users
```

### User Management

```bash
just create-user <username> '<ssh-ed25519 AAAA...>' staging   # or prod
just remove-user <username> prod
```

---

### Ansible Roles

| Role | Purpose |
|------|---------|
| common | Base system, NTP, sysctl |
| packages | User tools and language runtimes |
| security | SSH hardening, fail2ban, UFW |
| users | Skel, MOTD, user config |
| environment | Limits, quotas, tmpfs, pathing |
| services | Nginx, Gemini, Gopher |
| ftp | vsftpd |
| monitoring | Prometheus Node Exporter |
| backup | Borgmatic |

---

### Quality Control

```bash
pre-commit install
just lint
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [User Guide](docs/user-guide.md) | Getting started on atl.sh |
| [Admin Guide](docs/admin-guide.md) | Server administration |
| [FAQ](docs/faq.md) | Common questions |
| [Testing Guide](docs/testing.md) | Vagrant and local dev |
| [Code of Conduct](docs/code-of-conduct.md) | Community standards |

---

## License

[GNU GPL-3.0](LICENSE) — See [LICENSE](LICENSE) for full terms.
