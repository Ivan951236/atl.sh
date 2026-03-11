# Local Development Environment (Vagrant)

Test Ansible playbooks locally using a Vagrant VM before deploying to staging/production.

## Environments

- **dev** (Vagrant): Local VM for Ansible testing
- **staging** (Terraform): Cloud instance for pre-production validation
- **production** (Terraform): Live system

## Prerequisites

- [Vagrant](https://www.vagrantup.com/)
- [vagrant-libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt) + libvirt (KVM) — required; the Debian Trixie box does not support VirtualBox
- **dnsmasq** — required by libvirt for the default NAT network (DHCP/DNS for VMs)
- SSH key pair for dev access (create if missing):

```bash
mkdir -p .ssh
ssh-keygen -f .ssh/dev_key -t ed25519 -N ""
```

## Setup

### Arch Linux

**1. Install libvirt and QEMU**

```bash
sudo pacman -S libvirt qemu-base dnsmasq openbsd-netcat bridge-utils
```

**2. Add your user to the libvirt group**

```bash
sudo usermod -aG libvirt $(whoami)
```

Log out and back in (or run `newgrp libvirt`) for the group change to take effect.

**3. Enable and start libvirtd**

```bash
sudo systemctl enable --now libvirtd
```

**4. Verify libvirt**

```bash
virsh list --all
```

Should run without sudo and show an empty list (or existing VMs).

**5. Install Vagrant**

```bash
sudo pacman -S vagrant
```

**6. Install vagrant-libvirt plugin**

If you have `iptables` installed, remove it first (Arch uses `iptables-nft`):

```bash
sudo pacman -S iptables-nft pkg-config gcc make ruby
# If iptables exists: sudo pacman -Rns iptables  # remove conflicting package
vagrant plugin install vagrant-libvirt
```

**7. Provider**

`just dev-up` sets `VAGRANT_DEFAULT_PROVIDER=libvirt` automatically. If running `vagrant` directly, set `export VAGRANT_DEFAULT_PROVIDER=libvirt`.

### Other distros

- [Ubuntu/Debian](https://vagrant-libvirt.github.io/vagrant-libvirt/installation.html#ubuntu--debian)
- [Fedora](https://vagrant-libvirt.github.io/vagrant-libvirt/installation.html#fedora)
- [ArchWiki: libvirt](https://wiki.archlinux.org/title/libvirt)

## Quick Start

```bash
# 1. Start the dev VM
just dev-up

# 2. Wait for provisioning (~30–60 seconds first run)
# Vagrant will download the box, boot the VM, and configure root SSH access

# 3. Test SSH connection
ssh -i .ssh/dev_key -p 2223 -o StrictHostKeyChecking=no root@127.0.0.1

# 4. Run Ansible playbook against dev VM
just deploy dev

# Or with check mode (dry run):
cd ansible && ansible-playbook site.yml -l dev --check

# 5. Tear down when done
just dev-down
```

## Testing Specific Roles

```bash
cd ansible
ansible-playbook site.yml -l dev --tags common,packages
ansible-playbook site.yml -l dev --tags security -vvv
```

## Provider Notes

The `debian/trixie64` box supports only **libvirt** (KVM). If Vagrant picks VirtualBox by default, set `export VAGRANT_DEFAULT_PROVIDER=libvirt` before `just dev-up`.

### Vagrant–libvirt specifics

- **Port 2223**: vagrant-libvirt skips port forwarding when `id: "ssh"` (Vagrant's default). We use `id: "ssh_lh"` and port 2223 to avoid duplicate declarations with Vagrant's built-in 2222.
- **Synced folders disabled**: The default `/vagrant` sync uses NFS, which requires `nfs-common` in the guest. That can fail if the VM lacks IPv6 connectivity (apt tries IPv6 first for Debian mirrors). Ansible runs from the host over SSH, so no project files are needed in the VM.
- **Root SSH**: The provisioner copies `.ssh/dev_key.pub` to `/root/.ssh/authorized_keys` and runs `chown root:root` so sshd accepts the key (files uploaded by Vagrant are owned by the vagrant user).

## Troubleshooting

- **Provider mismatch / wrong VM state**: If you previously used VirtualBox or have stale state, remove `.vagrant` and re-run `just dev-up`:
  ```bash
  rm -rf .vagrant
  just dev-up
  ```
- **Plugin errors**: If Vagrant fails to initialize, try `vagrant plugin repair` or `vagrant plugin expunge --reinstall`
- **Provider not found**: Install `vagrant-libvirt` (Arch: `pacman -S vagrant libvirt`)
- **"Unable to find 'dnsmasq' binary"**: Libvirt needs dnsmasq for the default NAT network. Install it: `sudo pacman -S dnsmasq` (Arch)
- **"Permission denied (publickey)" for root@127.0.0.1**: The provisioner may have left `authorized_keys` owned by vagrant. Re-run `vagrant provision` (the provisioner now sets `chown root:root`). If it persists, `vagrant ssh` in and run `sudo chown root:root /root/.ssh/authorized_keys`.
- **Port 2223 in use**: Change the host port in the Vagrantfile (in the libvirt provider block, `override.vm.network`) and update `ansible_port` in `ansible/inventory/hosts.yml`. Use a port other than 2222 to avoid Vagrant's built-in default.
- **libvirt `virNetworkCreate` / `guest_nat` nftables error**: The default libvirt NAT network can conflict with nftables on Arch. See [libvirt - ArchWiki](https://wiki.archlinux.org/title/Libvirt#Using_nftables) and [nftables - ArchWiki](https://wiki.archlinux.org/title/Nftables).

  1. **Flush and reset**: Remove leftover libvirt tables and the default network, then restart:
     ```bash
     sudo nft delete table ip libvirt_network 2>/dev/null
     sudo nft delete table ip6 libvirt_network 2>/dev/null
     sudo virsh net-destroy default 2>/dev/null || true
     sudo virsh net-undefine default 2>/dev/null || true
     sudo systemctl restart libvirtd
     ```
     (libvirt recreates the default network on next `vagrant up`)

  2. **Allow virbr0 in nftables**: If you use a custom `/etc/nftables.conf` with `policy drop`, add rules so libvirt NAT works:
     ```
     iifname virbr0 udp dport {53, 67} accept    # in chain input
     iifname virbr0 accept                        # in chain forward
     oifname virbr0 accept                        # in chain forward
     ```
     See the libvirt ArchWiki "Using nftables" section for the full snippet.

  3. **Try iptables backend** (if your kernel supports it): Create `/etc/libvirt/network.conf` with `firewall_backend = "iptables"`, then restart libvirtd. **Note**: Zen kernel may lack legacy iptables modules; if you get "Table does not exist" errors, revert to nftables.

  4. **"No such file or directory" on `guest_nat` / `postrouting`** (nft NAT): Libvirt needs the `nft_nat` kernel module for NAT on the default network. If `modprobe nft_nat` fails with "Module not found", your running kernel lacks the module:
     - **Cause**: The `CONFIG_NFT_NAT` kernel option provides NAT chains in nftables; without the module, `type nat hook postrouting` fails.
     - **Fix**: Reinstall the kernel package so modules exist: `sudo pacman -S linux-zen`. If your running kernel (e.g. 6.18.5) no longer has a `/lib/modules/$(uname -r)/` directory (e.g. after an upgrade), boot into another kernel that has modules (e.g. 6.19.6) or reinstall the matching kernel.
     - **Verify**: `sudo modprobe nft_nat && sudo nft add table ip t; sudo nft add chain ip t p '{ type nat hook postrouting priority 100; }'` — if this succeeds, libvirt NAT should work.

## Notes

- SSH key authentication using `.ssh/dev_key` (not committed to git)
- SSH available on `127.0.0.1:2223` (see [Vagrant–libvirt specifics](#vagrantlibvirt-specifics) for why 2223)
- VM uses Debian 13 (Trixie) to match production
- Dev target runs full playbook including security and quotas
- Native systemd — all Ansible tasks run as they would on staging/prod
