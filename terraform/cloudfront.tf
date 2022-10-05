resource "aws_cloudfront_distribution" "eks_distribution" {
  origin {
    domain_name = aws_lb.eks-lb.dns_name
    origin_id   = aws_lb.eks-lb.dns_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }
  default_root_object = "/"
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFrond for EKS"
  default_cache_behavior {

    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_lb.eks-lb.dns_name
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  tags = {
    Name = "ClouFront for Hro"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  custom_error_response {
    error_code         = 403
    response_page_path = "/"
    response_code      = 200
  }
  custom_error_response {
    error_code         = 404
    response_page_path = "/"
    response_code      = 200
  }
}
output "domain" {
  value = aws_cloudfront_distribution.eks_distribution.domain_name
}