## Specifies the Region your Terraform Provider will server
provider "aws" {
  region = "eu-west-2"
}
## Specifies the S3 Bucket and DynamoDB table used for the durable backend and state locking

terraform {
  backend "s3" {
    encrypt = true
    bucket = "defender-tracker-terraform-state"
    key = "terraform.tfstate"
    region = "eu-west-2"
  }
}