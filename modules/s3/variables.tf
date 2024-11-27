variable "bucket_name" {
  description = "The name of the S3 bucket to be created"
  type        = string
}

variable "region" {
  description = "The region for the S3 bucket"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod) for tagging"
  type        = string
}