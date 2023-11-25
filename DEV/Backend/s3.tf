resource "aws_s3_bucket" "tf_course" {
    bucket = "s3-eks-blueprint-01-dev"
    acl = "private"
}
