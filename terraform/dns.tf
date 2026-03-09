# ──────────────────────────────────────────────
# Cloudflare DNS Records
# ──────────────────────────────────────────────

resource "cloudflare_record" "pubnix_a" {
  zone_id = var.cloudflare_zone_id
  name    = var.dns_subdomain
  content = hcloud_server.pubnix.ipv4_address
  type    = "A"
  ttl     = 300
  proxied = false # Direct connection needed for SSH/Gemini/Gopher
}
