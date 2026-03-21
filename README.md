# atl.sh

**atl.sh** is a public Unix environment (pubnix) for the [All Things Linux](https://allthingslinux.org) community. Get a shell account, host a personal website, and connect with others on a shared server.

---

## Quick Links

| For users | For admins |
|-----------|------------|
| [Get an account](https://portal.allthingslinux.org) | [Admin Guide](docs/admin-guide.md) |
| [User Guide](docs/user-guide.md) | [Operations](docs/operations.md) |
| [FAQ](docs/faq.md) | [Testing Guide](docs/testing.md) |
| [Documentation site](https://docs.atl.sh) | [Code of Conduct](docs/code-of-conduct.md) |

---

## Features

### Shell & Development

- **SSH access** on ports 22 and 2222 (key-only, passwords disabled)
- **Shells**: bash, zsh, fish, mksh
- **Editors**: vim, neovim, nano, emacs, micro, joe
- **Languages**: Python, Node.js, Go, Rust, Ruby, C/C++, Haskell, Elixir, Java, and 20+ more
- **Tools**: tmux, git, ripgrep, fzf, jq, bat, eza, lazygit, and many more
- **Package managers**: pip/pipx/uv, npm/pnpm, cargo, gem, go install — install to `~/.local/`

### Hosting & Protocols

- **Web**: Static sites at `https://atl.sh/~username` with CGI support
- **Gemini**: Capsules at `gemini://atl.sh/~username`
- **Gopher**: Holes at `gopher://atl.sh/~username`
- **FTP/S**: Explicit FTP over TLS (port 21); SFTP via SSH
- **Finger**: Profiles at `finger username@atl.sh` via `~/.plan` and `~/.project`

### Community

- **Webring**: Self-managing ring of member sites — join with `touch ~/.ring`
- **Games**: NetHack with shared high scores, botany virtual plant, angband, crawl, and arcade games
- **Messaging**: `write`, `talk`, `wall` for real-time user-to-user communication
- **IRC**: `#support` on `irc.atl.chat` (port 6697, SSL)

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
|:----------|:-----------|
| OS | Debian 13 (Trixie) |
| Configuration | Ansible |
| Infrastructure | Terraform (Hetzner Cloud, Cloudflare) |
| Web server | Nginx + fcgiwrap |
| Gemini | molly-brown |
| Gopher | Gophernicus |
| Finger | efingerd (systemd socket-activated) |
| FTP | vsftpd |
| Backups | Borgmatic (BorgBackup) |
| Monitoring | Prometheus Node Exporter, smartmontools, lm-sensors |
| Security | UFW, Fail2ban, Auditd, AIDE, unattended-upgrades |
| Docs | Fumadocs (Next.js, deployed to Cloudflare Workers) |

---

## Security

- **CIS hardening**: kernel parameters (ASLR, ptrace restrictions), network protections, module blacklisting
- **SSH**: key-only auth, ports 22 + 2222, max 3 auth attempts, allowed groups enforced
- **Fail2ban**: 1-hour bans after 5 failures in 10 minutes
- **Firewall**: UFW with allowlist — only necessary ports open
- **AIDE**: file integrity monitoring, daily checks at 05:00 UTC
- **Auditd**: 40+ rules covering identity files, privilege escalation, suspicious tools, and syscalls
- **Resource isolation**: systemd cgroup v2 user slices per user
- **Private `/tmp`**: `pam_namespace` polyinstantiation — each session gets an isolated tmpdir
- **Automatic updates**: unattended security upgrades

---

## Development

This project uses [just](https://github.com/casey/just) as a task runner. Run `just` to list all commands.

### Prerequisites

- [Ansible](https://docs.ansible.com/)
- [just](https://github.com/casey/just)
- [Vagrant](https://www.vagrantup.com/) + [vagrant-libvirt](https://github.com/vagrant-libvirt) (for local dev)
- [Terraform](https://www.terraform.io/) 1.8+ (for infrastructure)

```bash
just install   # install Ansible roles and collections
```

### Environments

| Target | Description |
|--------|-------------|
| `dev` | Local Vagrant VM (port 2223) |
| `staging` | Hetzner Cloud VPS |
| `prod` | Physical Hetzner server |

### Local Development

```bash
just dev-up          # start Vagrant VM
just deploy dev      # run Ansible against dev VM

# SSH into dev VM
ssh -p 2223 -i .ssh/dev_key root@127.0.0.1
```

Requires `.ssh/dev_key` and `.ssh/dev_key.pub` — see [docs/testing.md](docs/testing.md) for setup.

### Deployment

```bash
# Infrastructure
just tf-init
just tf-apply

# Configuration
just deploy prod

# Selective deploy by role tag
just deploy-tag prod infra
just deploy-tag prod services

# User management
just create-user <username> '<ssh-ed25519 AAAA...>' prod
just remove-user <username> prod
```

### Ansible Roles

| Role | Purpose |
|------|---------|
| `base` | Apt cache, base packages, NTP, shells, languages, editors, CLI tools |
| `infra` | SSH hardening, firewall, fail2ban, auditd, AIDE, monitoring, backups |
| `users` | Skel files, MOTD, PAM limits |
| `environment` | Cgroup limits, disk quotas, tmpfs isolation, XDG dirs, PATH |
| `services` | Nginx, Gemini, Gopher, finger, FTP, games, webring |

### Linting

```bash
pre-commit install
just lint          # runs pre-commit, ansible-lint, terraform fmt/validate
just syntax-check  # ansible playbook syntax check only
```

---

## Documentation

Full documentation is at **[docs.atl.sh](https://docs.atl.sh)**, built with Fumadocs and deployed to Cloudflare Workers from the `site/` directory.

Source docs also live in `docs/` as plain Markdown for quick reference.

---

## License

[GNU GPL-3.0](LICENSE)
