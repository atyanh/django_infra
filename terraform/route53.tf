resource "aws_route53_record" "root" {
  zone_id = var.dns_zone_id
  name    = "dard.life"
  type    = "A"
  ttl     = 300
  records = [aws_instance.ops_server.public_ip]
}