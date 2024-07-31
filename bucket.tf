module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.2.1"

  bucket = var.bucket_name
  acl = var.acl
  grant = var.grant
  lifecycle_rule = var.lifecycle_rule
  control_object_ownership = var.control_object_ownership
  object_ownership = var.object_ownership

  attach_policy = (var.encryption_policy || length(var.additional_statements) > 0 ) ? true : false
  policy        = (var.encryption_policy || length(var.additional_statements) > 0 ) ? data.aws_iam_policy_document.bucket_policy.json : ""

  versioning = {
    enabled = var.versioning_enabled
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.kms_master_key_id
        sse_algorithm     = var.sse_algorithm
      }
    }
  }

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  tags = var.tags

}

module "notifications" {
  count = (sum([length(var.lambda_notifications),length(var.sqs_notifications),length(var.sns_notifications)]) > 0) ? 1 : 0
  source = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version = "v3.2.1"

  bucket = module.s3_bucket.s3_bucket_id

  lambda_notifications = var.lambda_notifications
  sns_notifications = var.sns_notifications
  sqs_notifications = var.sqs_notifications

  create_sqs_policy = var.create_sqs_policy
  create_sns_policy = var.create_sns_policy

  depends_on = [module.s3_bucket]
}

module "object" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/object"
  create = var.create_object

  bucket     = module.s3_bucket.s3_bucket_id
  key        = var.key
  kms_key_id = var.kms_key_id
}
