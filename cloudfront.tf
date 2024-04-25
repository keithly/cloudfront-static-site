data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "site" {
  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
    origin_id                = aws_s3_bucket.site.bucket_regional_domain_name
  }

  aliases             = [data.aws_route53_zone.site.name, "www.${data.aws_route53_zone.site.name}"]
  enabled             = true
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  http_version        = "http2and3"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix          = var.cloudfront_logs_prefix
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.site.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  default_cache_behavior {
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = aws_s3_bucket.site.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rewrite_and_redirect.arn
    }
  }
}

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = aws_s3_bucket.site.bucket_regional_domain_name
  description                       = ""
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_function" "rewrite_and_redirect" {
  name    = "rewrite_and_redirect"
  runtime = "cloudfront-js-2.0"
  comment = "rewrite to add index.html, redirect bare domain to www"
  publish = true
  code    = file("rewrite_and_redirect.js")
}

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = var.bucket_name_cloudfront_logs
}

resource "aws_s3_bucket_ownership_controls" "logging" {
  bucket = aws_s3_bucket.cloudfront_logs.bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logging" {
  bucket = aws_s3_bucket.cloudfront_logs.bucket
  acl    = "log-delivery-write"

  depends_on = [aws_s3_bucket_ownership_controls.logging]
}

resource "aws_s3_bucket_lifecycle_configuration" "cf_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.bucket

  rule {
    id     = "expiration"
    status = "Enabled"

    expiration {
      days = var.cloudfront_logs_expiration_days
    }
  }
}
