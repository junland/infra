# Create primary zone.
resource "cloudflare_zone" "primary" {
  account = {
    id = var.cf_account_id
  }
  name = var.cf_primary_zone_name
  type = "full"
}

# Create CNAME record for the primary zone.
resource "cloudflare_dns_record" "primary" {
  name    = "www"
  content = var.cf_primary_zone_name
  zone_id = cloudflare_zone.primary.id
  proxied = false
  type    = "CNAME"
  ttl     = 300
}

# Create A records for hosts within the primary zone.
resource "cloudflare_dns_record" "host" {
  count   = length(var.cf_primary_hosts)
  name    = var.cf_primary_hosts[count.index].name
  proxied = false
  ttl     = 300
  type    = "A"
  content = var.cf_primary_hosts[count.index].ip
  zone_id = cloudflare_zone.primary.id
}

# Create CNAME records for services within the primary zone.
resource "cloudflare_dns_record" "service" {
  for_each = {
    for pair in flatten([
      for host in var.cf_primary_hosts : [
        for svc in host.svcs : {
          host_name = host.name
          svc_name  = svc
        }
      ]
    ]) : "${pair.svc_name}.${pair.host_name}" => pair
  }

  name    = "${each.value.svc_name}.${each.value.host_name}"
  proxied = false
  ttl     = 300
  type    = "CNAME"
  content = "${each.value.host_name}.${var.cf_primary_zone_name}"
  zone_id = cloudflare_zone.primary.id
}

# Create wildcard CNAME records for hosts within the primary zone.
resource "cloudflare_dns_record" "wildcard" {
  for_each = {
    for host in var.cf_primary_hosts : host.name => host if host.wildcard
  }

  name    = "*.${each.key}"
  proxied = false
  ttl     = 300
  type    = "CNAME"
  content = "${each.key}.${var.cf_primary_zone_name}"
  zone_id = cloudflare_zone.primary.id
}
