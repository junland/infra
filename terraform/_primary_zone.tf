# Create primary zone.
resource "cloudflare_zone" "primary" {
  zone = var.primary_zone_name
  type = "full"
}

# Create CNAME record for the primary zone.
resource "cloudflare_record" "primary" {
  name    = "www"
  value   = var.primary_zone_name
  zone_id = cloudflare_zone.primary.id
  proxied = false
  type    = "CNAME"
  ttl     = 3600
}

# Create A records for hosts within the primary zone.
resource "cloudflare_record" "host" {
  count   = length(var.primary_hosts)
  name    = var.primary_hosts[count.index].name
  value   = var.primary_hosts[count.index].ip
  zone_id = cloudflare_zone.primary.id
  proxied = false
  type    = "A"
  ttl     = 3600
}

# Create CNAME records for services within the primary zone.
resource "cloudflare_record" "service" {
  count   = length(var.primary_hosts)
  name    = var.primary_hosts[count.index].svcs
  value   = var.primary_hosts[count.index].name
  zone_id = cloudflare_zone.primary.id
  proxied = false
  type    = "CNAME"
  ttl     = 3600
}



