
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