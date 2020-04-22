resource "aws_iam_account_alias" "this" {
  account_alias = var.account_name
}

resource "aws_s3_bucket" "terraform-remote-state" {
  bucket = format("%s-%s", var.account_name, "terraform-remote-state")

  acl = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
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

resource "aws_dynamodb_table" "terraform-remote-state" {
  name         = format("%s-%s", var.account_name, "terraform-remote-state")
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
