variable "name" {
  type        = string
  description = "The name to give the S3 bucket - must be globally unique"
}

variable "s3_bucket_acl" {
  type        = string
  description = "The S3 pre-canned ACL to use for the bucket. Valid values are blanks, private, public-read, public-read-write and authenticated-read. Leave blank if using ACL grants"
  default     = "private"
  validation {
    condition     = contains(["", "private", "public-read", "public-read-write", "authenticated-read"], var.s3_bucket_acl)
    error_message = "Valid values for variable s3_bucket_acl: blanks, private, public-read, public-read-write, authenticated-read."
  }
}

variable "grant" {
  type        = any
  description = "ACL grants to be applied. Leave empty is using a non-blank value for the s3_bucket_acl variable"
  default     = []

}

variable "versioningrequired" {
  type        = string
  description = "Is versioning required? Yes or No. Check rules regarding S3 versioning requirements"
  default     = "No"
  validation {
    condition     = contains(["No", "Yes"], var.versioningrequired)
    error_message = "Valid values for variable versioningrequired: No, Yes."
  }
}

variable "s3_bucket_policy" {
  type        = string
  description = "Bucket Policy to be applied to the bucket"
  default = ""
}

variable "purpose" {
  type        = string
  description = "What is the bucket used for"
}

variable "itcontact" {
  type        = string
  description = "Email of group responsible for bucket"
}

variable "costcenter" {
  type        = string
  description = "Seven digits number of the Cost Center for bucket ownership"
  validation {
    condition     = length(var.costcenter) == 7
    error_message = "Valid values for variable removeondate must be a seven digits number."
  }
}

variable "businessline" {
  type        = string
  description = "Business Line responsible for bucket ownership"
}

variable "enviroment" {
  type        = string
  description = "Type of data stored in the bucket. Allowed values are: Production, Disaster Recovery, Test QA, Development,Vendor Provided, Scripts"
  default     = ""
  validation {
    condition     = contains(["Production", "Disaster Recovery", "Test QA", "Development", "Vendor Provided", "Scripts"], var.enviroment)
    error_message = "Valid values for variable enviroment: Production, Disaster Recovery, Test QA, Development,Vendor Provided, Scripts."
  }
}

variable "publicaccessallowed" {
  type        = string
  description = "Yes or No. Will be used for future automations"
  default     = "No"
  validation {
    condition     = contains(["No", "Yes"], var.publicaccessallowed)
    error_message = "Valid values for variable publicaccessallowed: No, Yes."
  }
}

variable "removeondate" {
  type        = string
  description = "If bucket is used for POC or testing, provide date on when to delete the bucket in format YYYYMMDD. If bucket required permanently, then use 20301231"
  default     = "20301231"
  validation {
    condition     = length(var.removeondate) == 8
    error_message = "Valid values for variable removeondate must be a date in format YYYYMMDD."
  }
}

variable "sse_algorithm" {
  type        = string
  description = "The server-side encryption algorithm to use. Valid values are AES256 (for SSE-S3) and aws:kms"
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "Valid values for variable sse_algorithm: AES256, aws:kms."
  }
}
variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key is using aws:kms as encryption type. Leave blank if using  AWS managed key for aws:kms"
  default     = ""
}

variable "bucket_key_enabled" {
  type        = bool
  description = "Whether to use Amazon S3 Bucket Keys. Use false when not requested"
  default     = false
  validation {
    condition     = contains([true, false], var.bucket_key_enabled)
    error_message = "Valid values for variable bucket_key_enabled are false or true."
  }
}

variable "bucket_ownership_control" {
  type        = string
  description = "Bucket Ownership controls. Valid values are BucketOwnerEnforced,BucketOwnerPreferred and ObjectWriter"
  default     = "BucketOwnerEnforced"
  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.bucket_ownership_control)
    error_message = "Valid values for variable bucket_ownership_control are BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter."
  }
}

variable "attach_public_policy" {
  description = "Controls if a user defined public bucket policy will be attached (set to `false` to allow upstream to apply defaults to the bucket)"
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = false
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = false
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = false
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "A map of additional tags. Required tags are set as mandatory variables"
  type        = map(any)
  default     = {}
}

locals {
  tags = {
    Purpose             = var.purpose,
    ITContact           = var.itcontact,
    CostCenter          = var.costcenter,
    BusinessLine        = var.businessline,
    Environment         = var.enviroment,
    VersioningRequired  = var.versioningrequired,
    PublicAccessAllowed = var.publicaccessallowed,
    RemoveOnDate        = var.removeondate,
    ManagedbyTerraform  = true
  }
}

variable "lifecycle_rule" {
  type        = any
  description = "A configuration of object lifecycle management"
  default     = []

}