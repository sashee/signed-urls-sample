resource "aws_s3_bucket" "frontend_bucket" {
  force_destroy = "true"
  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = data.aws_iam_policy_document.default.json
}

# bucket website is accessible to anyone
data "aws_iam_policy_document" "default" {
  statement {
    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

# Insert the backend URL into the HTML
data "template_file" "index" {
  template = file("${path.module}/index.html")
  vars = {
    backend_url = var.backend_url
  }
}

resource "aws_s3_bucket_object" "frontend_object_index_html" {
  key          = "index.html"
  content      = data.template_file.index.rendered
  bucket       = aws_s3_bucket.frontend_bucket.bucket
  etag         = md5(data.template_file.index.rendered)
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "frontend_object_main_js" {
  key          = "main.js"
  source       = "${path.module}/main.js"
  bucket       = aws_s3_bucket.frontend_bucket.bucket
  etag         = filemd5("${path.module}/main.js")
  content_type = "application/javascript"
}

