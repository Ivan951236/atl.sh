# atl.sh User Guide

## Getting Started

Welcome to atl.sh! You have a shell account on the All Things Linux community pubnix server.

### Connecting

```bash
ssh your-username@atl.sh
```

### Your Directories

| Directory          | Purpose                | Public URL                          |
|--------------------|------------------------|-------------------------------------|
| `~/public_html/`   | Personal web page      | `https://atl.sh/~your-username`     |
| `~/public_gemini/` | Gemini capsule         | `gemini://atl.sh/~your-username`    |
| `~/public_gopher/` | Gopher hole            | `gopher://atl.sh/~your-username`    |
| **FTP/S**         | **Home directory**     | `ftp://atl.sh` (Port 21, forced TLS) |

### Connecting
- **SSH**: `ssh your-username@atl.sh`
- **FTP/S**: Use an FTP client (like FileZilla) with **Explicit FTP over TLS**.

### Available Tools

We provide a wide range of tools including:

- **Shells**: bash, zsh, fish
- **Editors**: vim, neovim, nano, emacs
- **Languages**: Python, Node.js, Ruby, Go, C/C++
- **Utilities**: tmux, git, htop, ripgrep, jq, and more

### Log Management

We provide a standardized way for you to manage logs from your own processes (like CGI scripts or cron jobs):

- **Private Logs**: Store your log files in `~/.local/state/log`.
- **Auto-Rotation**: We provide a `.logrotate.conf` template in your home directory. If you configure it, the system will automatically rotate your logs daily to help you stay within your quota.

### Community

- **IRC**: `#support` on `irc.atl.chat` (port 6697, SSL)
- **Web**: [allthingslinux.org](https://allthingslinux.org)

### Rules

- Be respectful and follow the [Code of Conduct](code-of-conduct.md)
- No cryptocurrency mining
- No network abuse (scanning, DoS, spam)
- No illegal content
- Share and learn — that's what we're here for!
