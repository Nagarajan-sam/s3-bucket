# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

N/A

## 2.1.6 2024-06-25
- Added Object Ownership for S3 bucket.

## 2.1.5 2024-01-29
- Fixed the provider config to >=4.0

## 2.1.4 2023-12-22
- Added KMS key id in object module

## 2.1.3 2023-12-13
- Added lifecycle rule support for S3 bucket.

## 2.1.2 2023-12-04
- Added the object module to provide support to add folder in the s3 bucket.

## 2.1.1 2023-10-04
- Default acl to null so we don't get errors about setting the acl before we have permissions.
## 2.1.0

- Enhancing the sse algorithm options and removing restriction which only supported aws:kms. Parameterizing the algo, though keeping the default value as aws:kms only for backward compatibility.
- Removing the junk default value of 'kms_master_key_id' and setting it as null. As it becomes optional when algo used is AES256.

## 2.0.2

- Added support for grant statement from upstream s3 bucket module
## 2.0.1

- Fix to default the aws provider to ~> 4.0

## 2.0.0

- Update to latest version of community module. This brings in support for the 4.0 AWS provider.

## 1.1.1

- Lock s3 bucket module to latest version before community module went to the 4.0 AWS provider.
- Remove terraform version lock to 1.0.0

## 1.1.0

- Supports event notifications

## 1.0.2

- Changed bucket policy to include SSL

## 1.0.1

- Changed terraform version to 1.0.0 from 0.15.0

## 1.0.0

- Intial release
