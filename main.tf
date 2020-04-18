provider "aws" {
}

# S3 bucket

resource "aws_s3_bucket" "bucket" {
  force_destroy = "true"
}

# Lambda function

resource "random_id" "id" {
  byte_length = 8
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "/tmp/${random_id.id.hex}-lambda.zip"
  source {
    content  = file("backend.js")
    filename = "backend.js"
  }
}

resource "aws_lambda_function" "signer_lambda" {
  function_name = "signer-${random_id.id.hex}-function"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "backend.handler"
  runtime = "nodejs12.x"
  role    = aws_iam_role.lambda_exec.arn
  environment {
    variables = {
      BUCKET = aws_s3_bucket.bucket.bucket
    }
  }
}

data "aws_iam_policy_document" "lambda_exec_role_policy" {
  statement {
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_cloudwatch_log_group" "loggroup" {
  name              = "/aws/lambda/${aws_lambda_function.signer_lambda.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy" "lambda_exec_role" {
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_exec_role_policy.json
}

resource "aws_iam_role" "lambda_exec" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Action": "sts:AssumeRole",
	  "Principal": {
			"Service": "lambda.amazonaws.com"
	  },
	  "Effect": "Allow"
	}
  ]
}
EOF
}

# sample data

resource "aws_s3_bucket_object" "object" {
  for_each = toset(["tolstoy.pdf", "davinci.pdf"])

  key    = each.value
  source = "${path.module}/${each.value}"
  bucket = aws_s3_bucket.bucket.bucket
  etag   = filemd5("${path.module}/${each.value}")

  # open in the browser
  content_disposition = "inline"
  content_type        = "application/pdf"
}

# API Gateway

module "api" {
  source = "./modules/api"

  lambda_function = aws_lambda_function.signer_lambda
}

# Frontend bucket

module "frontend" {
  source = "./modules/frontend"

  backend_url = module.api.invoke_url
}

output "frontend_url" {
  value = module.frontend.url
}

