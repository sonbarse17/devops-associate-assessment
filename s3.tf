# s3.tf
resource "aws_s3_bucket" "devops_assoc_bucket" {
  bucket = "devops-assoc-bucket"

  tags = {
    Environment = "DevOpsTest"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.devops_assoc_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
