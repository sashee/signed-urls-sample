# S3 signed URLs sample code

## Prerequisities

* [Terraform](https://www.terraform.io/)

## Deploy

* ```terraform init```
* ```terraform apply```

It outputs the ```frontend_url``` which serves the index.html and main.js from the frontend bucket. You'll see 2 buttons: they
open an ebook using signed URLs from the private bucket.

## Delete

* ```terraform destroy```

## Structure

### [main.tf](main.tf)

This is the main entry point of the infrastructure. It creates the private bucket, the singer Lambda function with the necessary
permissions.

### [backend.js](backend.js)

This is the Node.js backend implementation of the Lambda function.

### [modules/api/main.tf](modules/api/main.tf)

The API Gateway to serve the Lambda function through a HTTP API.

### [modules/frontend/main.tf](modules/frontend/main.tf)

This creates a frontend bucket with website configuration, and deploys the index.html and the main.js.

### [modules/frontend/index.html](modules/frontend/index.html), [main.js](modules/frontend/main.js)

The frontend code is implemented in these files.
