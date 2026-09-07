# WARNING: This is intentionally configured for public access.
# This is for learning/demo purposes only and should not be used in production.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = "demo-public-bucket-1234567890"
}

resource "aws_s3_bucket_ownership_controls" "public_bucket" {
  bucket = aws_s3_bucket.public_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "public_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.public_bucket]

  bucket = aws_s3_bucket.public_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "public_bucket_block" {
  bucket = aws_s3_bucket.public_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "public_bucket_policy" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.public_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.public_bucket.id
  policy = data.aws_iam_policy_document.public_bucket_policy.json

  depends_on = [aws_s3_bucket_public_access_block.public_bucket_block]
}

output "bucket_name" {
  value = aws_s3_bucket.public_bucket.bucket
}

output "bucket_website_url" {
  value = "http://${aws_s3_bucket.public_bucket.bucket}.s3-website-us-east-1.amazonaws.com"
}
