#bku-sandbox-tagextractor

data "aws_canonical_user_id" "current" {}

locals {
  bucketname = "bku-sandbox-test-tfe"
}

#name module the same as the bucket name
module "bku-sandbox-test-tfe" {
  source  = "tfe.terraform.tools.c9bku.net/BankUnited/s3-bucket/aws"
  version = "0.0.5"
   #insert required variables here
  name = local.bucketname

  #acl and grant are mutually exclusive
  s3_bucket_acl = "private"

  #provide grant directly until I figure a way to get the list from a file

  grant = [
    {
    type        = "CanonicalUser"
    permissions = [
            "FULL_CONTROL"
        ]
    id          = data.aws_canonical_user_id.current.id
    }
  ]


  versioningrequired = "No"

   #bucket key enabled is false when using AWS encryption
  kms_key_arn = ""
  bucket_key_enabled = false

  itcontact = "CP-CLOUDARCH@BankUnited.Com"
  purpose = "bucket created to test the TFE module"
  costcenter ="1006704"
  businessline = "Network Engineer"
  enviroment = "Development"
  publicaccessallowed = "No"
  removeondate = "20220331"

  bucket_ownership_control = "ObjectWriter"
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true

  additional_tags = {
        }

  s3_bucket_policy = file("${path.module}/policies/bp-${local.bucketname}.json")
}