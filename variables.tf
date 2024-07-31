variable "bucket_name" {
  type = string
  description = "Name Of Bucket"
}

variable "acl" {
  type = string
  description = "Bucket ACL"
  default = null
}

variable "versioning_enabled" {
  type = bool
  description = "Enable Versioning for Bucket"
  default = true
}

variable "kms_master_key_id" {
  type = string
  description = "KMS Master Key To Use"
  default = null
}

variable "sse_algorithm" {
  type = string
  description = "Encryption Algorithm to use."
  default = "aws:kms"
}

variable "tags" {
  type = map(string)
  description = "Tags to add to buckets"
}

variable "block_public_acls" {
  type = bool
  default = true
}

variable "block_public_policy" {
  type = bool
  default = true
}

variable "ignore_public_acls" {
  type = bool
  default = true
}

variable "restrict_public_buckets" {
  type = bool
  default = true
}

variable "encryption_policy" {
  type = bool
  default = true
  description = "Whether to set the encryption policy"
}

variable "lifecycle_rule" {
  description = "S3 Bucket lifecycle rule configuration"
  type = any
  default = []
}

variable "ssl_policy" {
  type = bool
  default = true
  description = "Whether to set the ssl policy"
}

variable "additional_statements" {
  default = []
  type = list(object({
    sid                       = string
    actions                   = list(string)
    effect                    = string
    resources                 = list(string)
    principals                = list(object({
      type                        = string
      identifiers                 = list(string)
      })
    )
    condition                 = list(object({
      test                        = string
      variable                    = string
      values                      = list(string)
      })
    )
    })
  )
}

variable "lambda_notifications" {
  description = "Map of S3 bucket notifications to Lambda function"
  type        = any
  default     = {}
}

variable "sqs_notifications" {
  description = "Map of S3 bucket notifications to SQS queue"
  type        = any
  default     = {}
}

variable "sns_notifications" {
  description = "Map of S3 bucket notifications to SNS topic"
  type        = any
  default     = {}
}

variable "create_sns_policy" {
  description = "Whether to create a policy for SNS permissions or not"
  type        = bool
  default     = true
}

variable "create_sqs_policy" {
  description = "Whether to create a policy for SQS permissions or not"
  type        = bool
  default     = true
}

variable "grant" {
  description = "An ACL policy grant. Conflicts with `acl`"
  type        = any
  default     = []
}

variable "key" {
  type = string
  description = "Bucket folder structure"
  default = null
}

variable "create_object" {
  type = bool
  description = "Enable Objects in Bucket"
  default = true
}

variable "kms_key_id" {
  description = "Amazon Resource Name (ARN) of the KMS Key to use for object encryption. If the S3 Bucket has server-side encryption enabled, that value will automatically be used. If referencing the aws_kms_key resource, use the arn attribute. If referencing the aws_kms_alias data source or resource, use the target_key_arn attribute. Terraform will only perform drift detection if a configuration value is provided."
  type        = string
  default     = null
}

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. 'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket. 'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL. 'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL."
  type        = string
  default     = "BucketOwnerEnforced"
}