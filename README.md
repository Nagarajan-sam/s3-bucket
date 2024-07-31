# AWS-S3-BUCKET

## Change Log

- Intial Version 1.0.0 (includes)

## Details

This module:

- Creates an S3 bucket
- Creates a bucket policy
- Can create event_notifications
- Can create event notification policies for the destination (e.g. sqs policy)

Usage
In order to use the module you would call it from a Terragrunt live repo the following way.

```
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  app_environment = local.environment_vars.locals.app_environment
  infra_env = replace(local.environment_vars.locals.infrastructure_environment,"_", "-")
  bucket_name = "dpx-${local.infra_env}-${local.app_environment}-file-ingestion"
  modules_version = "1.0.2"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::ssh://git@bitbucket.deluxe.com:7999/dtf/aws-s3-bucket.git//?ref=${local.modules_version}"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "kms-s3-file-ingestion-key" {
  config_path = "${get_terragrunt_dir()}/../../_global/kms-s3-file-ingestion-key"

  mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
  mock_outputs = {
    kms_arn = "arn::"
    kms_id = "key_id"
    kms_key_alias_arn = "arn::"
  }
}

dependency "common-tags" {
  config_path = "${get_terragrunt_dir()}/../../_global/common-tags"

  mock_outputs_allowed_terraform_commands = ["validate","plan","destroy", "plan-all"]
  mock_outputs = {
    asg_common_tags = [
      {
        key = "AccountId"
        propagate_at_launch = true
        value = "3432"
      }
    ]
    common_tags = {
      "AppName" = "DPX-File-Ingestion"
    }
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  bucket_name = local.bucket_name
  acl = "private"
  versioning_enabled = true
  kms_master_key_id = dependency.kms-s3-file-ingestion-key.outputs.kms_arn
  encryption_policy = false
  sqs_notifications = {
    sqs-dpx-file-ingestion = {
      events = ["s3:ObjectCreated:*"]
      queue_arn = dependency.sqs-dpx-file-ingestion.outputs.queue_arn
    }
  }
  tags = merge(dependency.common-tags.outputs.common_tags, {
    "TerraformPath" = path_relative_to_include()
    "Name" = local.bucket_name
  })
}
```

NOTE: If using the SQS S3 Notification Event, and an encrypted queue, you must add the policy below to the KMS key used to encrypt the queue;

Assuming using the aws-kms-key module;

```
  additional_policy = [{
    sid = "AllowS3AccessToKms"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    effect = "Allow"
    principals = [{
      type = "Service"
      identifiers = [
        "s3.amazonaws.com"
      ]
    }]
    resources = [
      "*"
    ]
    condition = []
  }]
```
