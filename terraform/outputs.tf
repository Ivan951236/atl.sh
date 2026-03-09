output "server_ip" {
  description = "IPv4 address of the pubnix test VPS"
  value       = hcloud_server.pubnix.ipv4_address
}

output "server_id" {
  description = "Hetzner server ID"
  value       = hcloud_server.pubnix.id
}

output "server_status" {
  description = "Server status"
  value       = hcloud_server.pubnix.status
}

output "dns_record" {
  description = "DNS record pointing to the VPS"
  value       = "${var.dns_subdomain}.atl.sh"
}
