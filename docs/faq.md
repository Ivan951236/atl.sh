# Frequently Asked Questions

## What is atl.sh?

atl.sh is a pubnix (public-access Unix server) run by the All Things Linux community. You get a shell account with web hosting, Gemini, and Gopher support.

## How do I get an account?

Sign up through the [ATL Portal](https://portal.allthingslinux.com). Your shell account is provisioned automatically.

## How do I connect?

```bash
ssh your-username@atl.sh
```

## How do I make a web page?

Edit `~/public_html/index.html`. Your page will be live at `https://atl.sh/~your-username`.

## What is Gemini?

Gemini is a lightweight internet protocol — a simpler alternative to the web. Edit `~/public_gemini/index.gmi` to create your capsule.

## What is Gopher?

Gopher is a classic internet protocol from 1991. Edit `~/public_gopher/gophermap` to create your gopher hole.

## Can I install my own software?

You can install software to `~/.local/` using language package managers (pip, npm, gem, cargo). System packages are managed by admins — suggest additions on IRC.

## What are the resource limits?

- Disk: 5GB soft / 6GB hard (XFS/Ext4 Quotas)
- Processes (Tasks): 200 max (systemd cgroups)
- Memory: 1.5GB RAM max
- CPU: 200% (2 cores) max

## Is this free?

Yes, always. Supported by the All Things Linux community.
