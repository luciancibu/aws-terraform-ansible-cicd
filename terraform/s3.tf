resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "ansible_deploy" {
  bucket = "ansible-cicd-deploy-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.ansible_deploy.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.ansible_deploy.id

  versioning_configuration {
    status = "Disabled"
  }
}
