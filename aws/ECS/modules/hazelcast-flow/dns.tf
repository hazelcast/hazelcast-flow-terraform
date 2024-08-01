resource "aws_route53_record" "ui" {
  zone_id = var.route53_zone_id
  name    = "flow.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_alb.flow.dns_name
    zone_id                = aws_alb.flow.zone_id
    evaluate_target_health = true
  }
}

resource "aws_alb_listener" "flow" {
  load_balancer_arn = aws_alb.flow.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.cert_arn
  default_action {
    type             = "forward"
    target_group_arn = module.flow.target_group_arn
  }
}

resource "aws_route53_record" "mc" {
  zone_id = var.route53_zone_id
  name    = "mc.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_alb.mc.dns_name
    zone_id                = aws_alb.mc.zone_id
    evaluate_target_health = true
  }
}

resource "aws_alb_listener" "mc" {
  load_balancer_arn = aws_alb.mc.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.cert_arn
  default_action {
    type             = "forward"
    target_group_arn = module.mc.target_group_arn
  }
}