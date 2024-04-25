data "aws_acm_certificate" "site" {
  domain   = var.domain_name
  provider = aws.us-east-1
}

data "aws_route53_zone" "site" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "site_a" {
  zone_id = data.aws_route53_zone.site.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_aaaa" {
  zone_id = data.aws_route53_zone.site.zone_id
  name    = ""
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_a_www" {
  zone_id = data.aws_route53_zone.site.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_aaaa_www" {
  zone_id = data.aws_route53_zone.site.zone_id
  name    = "www"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}


resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.bucket
  policy = data.aws_iam_policy_document.allow_cloudfront_oac_access.json
}

data "aws_iam_policy_document" "allow_cloudfront_oac_access" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.site.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}