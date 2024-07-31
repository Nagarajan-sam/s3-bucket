data "aws_iam_policy_document" "bucket_policy" {
  source_policy_documents = compact([
    data.aws_iam_policy_document.generated_policy.json,
    var.encryption_policy ? data.aws_iam_policy_document.enforce_encryption_headers[0].json : data.aws_iam_policy_document.empty.json,
    var.ssl_policy ? data.aws_iam_policy_document.ssl_requirement[0].json : data.aws_iam_policy_document.empty.json
  ])
}

data "aws_iam_policy_document" "empty" {
}

data "aws_iam_policy_document" "enforce_encryption_headers" {
  count = var.encryption_policy ? 1 : 0
  statement {
    sid = "DenyIncorrectEncryptionHeader"
    actions = [
      "s3:PutObject",
    ]

    effect = "Deny"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    resources = [
      "arn:aws:s3:::${var.bucket_name}/*",
    ]
    condition {
      test = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values = ["aws:kms","AES256"]
    }
  }

  statement {
    sid = "DenyUnEncryptedObjectUploads"
    actions = [
      "s3:PutObject",
    ]

    effect = "Deny"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    resources = [
      "arn:aws:s3:::${var.bucket_name}/*",
    ]
    condition {
      test = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values = ["true"]
    }
  }
}

# Satisfy requirement to require SSL connections when talk to S3 Buckets .  We will also suppport disabling this if needed.

data "aws_iam_policy_document" "ssl_requirement" {
  count = var.ssl_policy ? 1 : 0
  statement {
    sid = "ForceSSLOnlyAccess"
    actions = [
      "s3:*",
    ]

    effect = "Deny"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    resources = [
      "arn:aws:s3:::${var.bucket_name}/*",
      "arn:aws:s3:::${var.bucket_name}",
    ]
    condition {
      test = "Bool"
      variable = "aws:SecureTransport"
      values = ["false"]
    }
  }
}

data "aws_iam_policy_document" "generated_policy" {
  dynamic "statement" {
    for_each = [for s in var.additional_statements: {
      sid = s.sid
      actions = s.actions
      effect = s.effect
      resources = s.resources
      principals = s.principals
      condition = s.condition
    }]
    content {
      sid = statement.value.sid
      actions = statement.value.actions
      effect = statement.value.effect
      resources = statement.value.resources

      dynamic "principals" {
        for_each = [for p in statement.value.principals: {
          principal_type = p.type
          principal_identifiers = p.identifiers
        }]
        content {
          type = principals.value.principal_type
          identifiers = principals.value.principal_identifiers
        }
      }
      dynamic "condition" {
        for_each = [for c in statement.value.condition: {
          condition_test = c.test
          condition_variable = c.variable
          condition_values = c.values
        }]
        content {
          test = condition.value.condition_test
          variable = condition.value.condition_variable
          values = condition.value.condition_values
        }
      }
    }
  }
}
