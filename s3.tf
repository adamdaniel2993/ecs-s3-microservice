locals {
  bucket_name = "nova-bucket-exam"
}

resource "aws_s3_bucket" "nova_s3" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "nova_boc" {
  bucket = aws_s3_bucket.nova_s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "nova_pab" {
  bucket = aws_s3_bucket.nova_s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.nova_boc,
    aws_s3_bucket_public_access_block.nova_pab,
  ]

  bucket = aws_s3_bucket.nova_s3.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "nova_static_s3_web" {
  bucket = aws_s3_bucket.nova_s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  # Routing for accountservice
  routing_rule {
    condition {
      key_prefix_equals = "accountservice/"
    }
    redirect {
      replace_key_prefix_with = ""
      protocol                = "http"
      host_name               = aws_lb.nova_alb.dns_name
      http_redirect_code      = "302"
    }
  }

  # Routing for inventoryservice
  routing_rule {
    condition {
      key_prefix_equals = "inventoryservice/"
    }
    redirect {
      replace_key_prefix_with = ""
      protocol                = "http"
      host_name               = aws_lb.nova_alb.dns_name
      http_redirect_code      = "302"
    }
  }

  # Routing for shippingservice
  routing_rule {
    condition {
      key_prefix_equals = "shippingservice/"
    }
    redirect {
      replace_key_prefix_with = ""
      protocol                = "http"
      host_name               = aws_lb.nova_alb.dns_name
      http_redirect_code      = "302"
    }
  }
}
