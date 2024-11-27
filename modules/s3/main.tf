resource "aws_s3_bucket" "example_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "${var.bucket_name}-${var.environment}"
    Environment = var.environment
    Region      = var.region
  }
}

resource "aws_s3_object" "app_tier" {
  for_each = fileset("./application-code/app-tier", "**/*")
  bucket   = aws_s3_bucket.example_bucket.bucket
  key      = "app-tier/${each.value}"
  source   = "./application-code/app-tier/${each.value}"
  acl      = "private"
}

resource "aws_s3_object" "web_tier" {
  for_each = fileset("./application-code/web-tier", "**/*")
  bucket   = aws_s3_bucket.example_bucket.bucket
  key      = "web-tier/${each.value}"
  source   = "./application-code/web-tier/${each.value}"
  acl      = "private"
}