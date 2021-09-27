provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "dyson1602-up-and-running"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }

  # Enable versioning so we can see the full revision history of our state files
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "dyson1602-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Partial configuration. The other settings (eg bucket, region) will be passed
# in from a file via -backend-config arguments to terraform init

terraform {
  backend "s3" {
    bucket = "dyson1602-up-and-running"
    key    = "workspaces-example/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "dyson1602-up-and-running-locks"
    encrypt        = true
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
