data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

provider "aws" {
  region = "us-east-1"
}



resource "aws_s3_bucket" "bucket" {
  bucket = var.name
  acl    = var.s3_bucket_acl != "" ? var.s3_bucket_acl : null

  dynamic "grant" {
    for_each = try(jsondecode(var.grant), var.grant)

    content {
      id          = lookup(grant.value, "id", null)
      type        = grant.value.type
      permissions = grant.value.permissions
      uri         = lookup(grant.value, "uri", null)
    }
  }

  dynamic "lifecycle_rule" {
    for_each = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)

    content {
      id      = lookup(lifecycle_rule.value, "id", null)
      prefix  = lookup(lifecycle_rule.value, "prefix", null)
      enabled = lookup(lifecycle_rule.value, "enabled", true)

      tags = try(lifecycle_rule.value.tags, lifecycle_rule.value.tags, {})
 

      # Several blocks - transition
      dynamic "transition" {
        for_each = try(flatten(lifecycle_rule.value.transition), [])
        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = lookup(transition.value, "storage_class", null)
        }
      }
      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = try(flatten(lifecycle_rule.value.expiration), [])
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }
      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten(lifecycle_rule.value.noncurrent_version_expiration), [])
        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }
      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = try(flatten(lifecycle_rule.value.noncurrent_version_transition), [])
        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = lookup(noncurrent_version_transition.value, "storage_class", null)
        }
      }
    }

  }

  versioning {
    enabled = lookup({ "Yes" = "true", "No" = "false" }, var.versioningrequired, "false")
  }
  tags = merge(var.additional_tags, local.tags)


  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.sse_algorithm

        kms_master_key_id = (var.sse_algorithm == "aws:kms" ? var.kms_key_arn : "")

      }
      bucket_key_enabled = (var.sse_algorithm == "aws:kms" ? var.bucket_key_enabled : false)
    }
  }
  /*
  logging {
    target_bucket = local.access-logs-targets[join("-", [data.aws_region.current.name, data.aws_caller_identity.current.account_id])]
    target_prefix = join("", [var.name, "/"])
  }*/
}

/*resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::/*",
        "arn:aws:s3:::"
      ],
      "Effect": "Deny",
      "Condition": {
        "StringNotEquals": {
          "aws:sourceVpce": ""
        }
      }
    }
  ]
}
POLICY
}*/

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = var.bucket_ownership_control
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {

  count = var.attach_public_policy ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_public_access_block" "bucketpublic" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  restrict_public_buckets = true
}