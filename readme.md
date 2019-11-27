# S3 signed URLs sample code

## Prerequisities

* Terraform

## Deploy

* terraform init
* terraform apply

It outputs the ```frontend_url``` which serves the index.html and main.js from the frontend bucket. You'll see 2 buttons: they
open an ebook using signed URLs from the private bucket.

## Destory

* terraform destroy

## Structure

### main.tf

This is the main entry point of the infrastructure. It creates the private bucket, the singer Lambda function with the necessary
permissions.

### backend.js

This is the Node.js backend implementation of the Lambda function.

### modules/api/main.tf

The API Gateway to serve the Lambda function through a HTTP API.

### modules/frontend/main.tf

This creates a frontend bucket with website configuration, and deploys the index.html and the main.js.

### modules/frontend/index.html, main.js

The frontend code is implemented in these files.
