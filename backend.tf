resource "aws_s3_bucket" "this" {
  bucket = "terraform-state-bucket-ashwani-93120665"
  tags = {
    Name = "terraform-state-bucket-ashwani-93120665"
  }
  force_destroy = false
}
