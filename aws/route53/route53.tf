resource "aws_route53_zone" "main" {
  name = "spicedelver.me"
}

resource "aws_route53_record" "ns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "spicedelver.me"
  type    = "NS"
  ttl     = 172800
  records = [
    "ns-1429.awsdns-50.org.",
    "ns-485.awsdns-60.com.",
    "ns-1800.awsdns-33.co.uk.",
    "ns-947.awsdns-54.net."
  ]
}

resource "aws_route53_record" "soa" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "spicedelver.me"
  type    = "SOA"
  ttl     = 900
  records = [
    "ns-1429.awsdns-50.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
  ]
}

# resource "aws_route53_record" "public_ip_entry" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "*.spicedelver.me"
#   type    = "A"
#   ttl     = 300
#   records = [
# resource "aws_route53_record" "public_ip_entry" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "*.spicedelver.me"
#   type    = "A"
#   ttl     = 300
#   records = [
#     "142.167.12.134"
#   ]
# }
#     "142.167.12.134"
#   ]
# }

resource "aws_route53_record" "private_ip_entry" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "*.home.spicedelver.me"
  type    = "A"
  ttl     = 300
  records = [var.ip_range[0]]
}

resource "aws_route53_record" "proxmox_ip_entry" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "proxmox.home.spicedelver.me"
  type    = "A"
  ttl     = 300
  records = [for d in data.tailscale_devices.homelab.devices : d.addresses[0] if contains(d.tags, "tag:proxmox")]
}

resource "aws_route53_record" "nas_ip_entry" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "nas.home.spicedelver.me"
  type    = "A"
  ttl     = 300
  records = [
    var.nas_ip,
  ]
}

resource "aws_route53_record" "cluster_ip_entry" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "cluster.home.spicedelver.me"
  type    = "A"
  ttl     = 300
  records = var.controlplane_ip
}
