# ──────────────────────────────────────────────
# Hetzner Cloud
# ──────────────────────────────────────────────

variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name of the test VPS"
  type        = string
  default     = "atl-pubnix-test"
}

variable "server_type" {
  description = "Hetzner server type (CX32 = 4 vCPU, 8GB RAM)"
  type        = string
  default     = "cx32"
}

variable "server_location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "fsn1"
}

variable "server_image" {
  description = "OS image for the server"
  type        = string
  default     = "debian-13"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key for admin access"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

# ──────────────────────────────────────────────
# Cloudflare DNS
# ──────────────────────────────────────────────

variable "cloudflare_api_token" {
  description = "Cloudflare API token with DNS edit permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for atl.sh"
  type        = string
}

variable "dns_subdomain" {
  description = "Subdomain to point at the test VPS (e.g., 'test' → test.atl.sh)"
  type        = string
  default     = "test"
}
