# Terraform Configuration
terraform {
  backend "s3" {
    bucket = "testcreate"
    key    = "tftest/web"
    region = "ap-south-1"
  }
}
