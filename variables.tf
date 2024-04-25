variable "domain_name" {
  description = "Domain name of the site / existing Route53 hosted zone name"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "bucket_name_cloudfront_logs" {
  description = "S3 bucket name for CloudFront logs"
  type        = string
}

variable "cloudfront_logs_prefix" {
  description = "S3 prefix for CloudFront logs"
  type        = string
}

variable "cloudfront_logs_expiration_days" {
  description = "days to keep CloudFront logs"
  type        = number
}
