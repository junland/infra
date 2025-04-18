# Create primary zone.
resource "cloudflare_zone" "primary" {
  account = {
    id = var.cf_account_id
  }
  name = var.primary_zone_name
  type = "full"
}

# Create CNAME record for the primary zone.
resource "cloudflare_dns_record" "primary" {
  name    = "www"
  content = var.primary_zone_name
  zone_id = cloudflare_zone.primary.id
  proxied = false
  type    = "CNAME"
  ttl     = 3600
}

# Create A records for hosts within the primary zone.
resource "cloudflare_dns_record" "host" {
  count   = length(var.primary_hosts)
  name    = var.primary_hosts[count.index].name
  proxied = false
  ttl     = 3600
  type    = "A"
  content = var.primary_hosts[count.index].ip
  zone_id = cloudflare_zone.primary.id
}

# Create CNAME records for services within the primary zone.
resource "cloudflare_dns_record" "service" {
  count   = length(var.primary_hosts)
  name    = var.primary_hosts[count.index].svcs
  proxied = false
  ttl     = 3600
  type    = "CNAME"
  content = var.primary_hosts[count.index].name
  zone_id = cloudflare_zone.primary.id
}

# Get account id



