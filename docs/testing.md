# Local Docker Development Environment

Test Ansible playbooks locally using Docker before deploying to staging/production.

## Environments

- **dev** (Docker): Local container for rapid testing
- **staging** (Terraform): Cloud instance for pre-production validation
- **production** (Terraform): Live system

## Quick Start

```bash
# 1. Start the dev container
docker compose up -d

# 2. Wait for SSH to start (~3 seconds)
sleep 3

# 3. Test SSH connection
ssh -i .ssh/dev_key -p 2222 -o StrictHostKeyChecking=no root@localhost

# 4. Run Ansible playbook against dev container
cd ansible
ansible-playbook -i inventory/dev.ini site.yml --check

# 5. Apply changes (remove --check)
ansible-playbook -i inventory/dev.ini site.yml

# 6. Tear down when done
docker compose down
```

## Testing Specific Roles

```bash
# Test only security role
ansible-playbook -i inventory/dev.ini site.yml --tags security

# Test with verbose output
ansible-playbook -i inventory/dev.ini site.yml -vvv
```

## Rebuilding Container

```bash
# Rebuild after Containerfile changes
docker compose build --no-cache
docker compose up -d
```

## Notes

- SSH key authentication using `.ssh/dev_key` (not committed to git)
- SSH available on `localhost:2222`
- Container uses Debian 13 (Trixie) to match production
- Changes are ephemeral - destroyed when container stops
- No systemd - some tasks requiring systemd will be skipped
