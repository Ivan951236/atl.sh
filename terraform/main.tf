# ──────────────────────────────────────────────
# SSH Key
# ──────────────────────────────────────────────

resource "hcloud_ssh_key" "admin" {
  name       = "${var.server_name}-admin"
  public_key = file(var.ssh_public_key_path)
}

# ──────────────────────────────────────────────
# Firewall
# ──────────────────────────────────────────────

resource "hcloud_firewall" "pubnix" {
  name = "${var.server_name}-fw"

  # SSH
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # HTTP
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # Gopher
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "70"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # Gemini
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "1965"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

# ──────────────────────────────────────────────
# Server
# ──────────────────────────────────────────────

resource "hcloud_server" "pubnix" {
  name        = var.server_name
  server_type = var.server_type
  location    = var.server_location
  image       = var.server_image

  ssh_keys = [hcloud_ssh_key.admin.id]

  firewall_ids = [hcloud_firewall.pubnix.id]

  labels = {
    project     = "atl-pubnix"
    environment = "test"
  }
}

# ──────────────────────────────────────────────
# Reverse DNS
# ──────────────────────────────────────────────

resource "hcloud_rdns" "pubnix_ipv4" {
  server_id  = hcloud_server.pubnix.id
  ip_address = hcloud_server.pubnix.ipv4_address
  dns_ptr    = "${var.dns_subdomain}.atl.sh"
}
