# Get the certificate from AWS ACM
# data "aws_acm_certificate" "issued" {
#   domain   = var.certificate_domain_name
#   statuses = ["ISSUED"]
# }

#creating Cloudfront distribution :
resource "aws_cloudfront_distribution" "my_distribution" {
  enabled = true
  # aliases             =  [var.additional_domain_name]      # For custom domain name
  origin {
    domain_name = var.internet_facing_alb_domain_name
    origin_id   = var.internet_facing_alb_domain_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.internet_facing_alb_domain_name
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      headers      = ["Host"]
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["LK", "US"]
    }
  }

  tags = {
    Name = var.project_name
  }

  # For Default Certificate
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # For custom ACM Certificate
  # viewer_certificate {
  #   acm_certificate_arn      = data.aws_acm_certificate.issued.arn
  #   minimum_protocol_version = "TLSv1.2"
  #   ssl_support_method       = "sni-only"
  # }

  price_class = "PriceClass_200"
}