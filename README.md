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
| Gemini / Gopher | gmid, Gophernicus |
| Backups | Borgmatic |
| Security | UFW, Fail2ban, systemd user slices |

## Security and Isolation

The system implements multiple layers of protection to ensure stability for all users:

- **Resource Limits**: systemd user slices enforce kernel-level caps on CPU, memory, and process count per user.
- **Hardened /tmp**: User-specific temporary directories are mounted as `tmpfs` with `nodev`, `nosuid`, and `noexec` options.
- **Quotas**: User and group filesystem quotas are enforced on the root partition.
- **Network**: SSH is rate-limited and protected by Fail2ban.

## Deployment

### Prerequisites
Install necessary Ansible collections:
```bash
ansible-galaxy install -r requirements.yml
```

### Infrastructure and Configuration
```bash
# Provision infrastructure
cd terraform && terraform init && terraform apply

# Apply configuration
cd ../ansible && ansible-playbook site.yml
```

### Quality Control
Pre-commit hooks are used to maintain code quality:
```bash
pre-commit install
pre-commit run --all-files
```

## Documentation

- [User Guide](docs/user-guide.md)
- [Admin Guide](docs/admin-guide.md)
- [Architecture](docs/architecture.md)
