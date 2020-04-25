locals {
  account_name = format("%s-%s", var.client, var.name)
}

resource "aws_iam_account_alias" "this" {
  account_alias = local.account_name
}

resource "aws_s3_bucket" "terraform-remote-state" {
  bucket = format("%s-%s", local.account_name, "terraform-remote-state")

  acl = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform-remote-state" {
  bucket = aws_s3_bucket.terraform-remote-state.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_dynamodb_table" "terraform-remote-state" {
  name         = format("%s-%s", local.account_name, "terraform-remote-state")
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    ManagedBy = "Terraform"
  }
}

data "aws_kms_alias" "ssm" {
  name = "alias/aws/ssm"
}

resource "aws_ssm_parameter" "config_client" {
  type  = "SecureString"
  name  = "/terraform/${local.account_name}/config/client"
  value = var.client

  key_id = data.aws_kms_alias.ssm.target_key_id

  overwrite = true

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_ssm_parameter" "config_name" {
  type  = "SecureString"
  name  = "/terraform/${local.account_name}/config/name"
  value = var.name

  key_id = data.aws_kms_alias.ssm.target_key_id

  overwrite = true

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_ssm_parameter" "backend_dynamodb_table" {
  type  = "SecureString"
  name  = "/terraform/${local.account_name}/backend/dynamodb_table"
  value = format("%s-%s", local.account_name, "terraform-remote-state")

  key_id = data.aws_kms_alias.ssm.target_key_id

  overwrite = true

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_ssm_parameter" "backend_bucket" {
  type  = "SecureString"
  name  = "/terraform/${local.account_name}/backend/bucket"
  value = format("%s-%s", local.account_name, "terraform-remote-state")

  key_id = data.aws_kms_alias.ssm.target_key_id

  overwrite = true

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_ssm_parameter" "backend_key" {
  type  = "SecureString"
  name  = "/terraform/${local.account_name}/backend/key"
  value = "account-${var.name}.tfstate"

  key_id = data.aws_kms_alias.ssm.target_key_id

  overwrite = true

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_ssm_parameter" "backend_region" {
  type  = "SecureString"
  name  = "/terraform/${local.account_name}/backend/region"
  value = var.home_region

  key_id = data.aws_kms_alias.ssm.target_key_id

  overwrite = true

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_ssm_parameter" "backend_encrypt" {
  type  = "SecureString"
  name  = "/terraform/${local.account_name}/backend/encrypt_true"
  value = "true"

  key_id = data.aws_kms_alias.ssm.target_key_id

  overwrite = true

  tags = {
    ManagedBy = "Terraform"
  }
}
