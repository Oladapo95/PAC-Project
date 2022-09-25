provider "aws" {
  region  = "eu-west-2"
  profile = "personal"
}

#Create bucket for storing state file
resource "aws_s3_bucket" "pacpet1_state_bucket_d" {
  bucket = "pacpet1-state-bucket-d"
  force_destroy = true
}

# Enable versioning so we can see the full revision history of our state files
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.pacpet1_state_bucket_d.id
  versioning_configuration {
    status = "Enabled"
  }
}


# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.pacpet1_state_bucket_d.id
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
}

#Create resource to lock the state file
#So no two people can run apply, destory, plan at same time
resource "aws_dynamodb_table" "pacpet1_dynamo_table" {
  name         = "pacpet1_dynamo_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}