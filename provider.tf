## Specifies the Region your Terraform Provider will server
provider "aws" {
  region = "eu-west-2"
  assume_role_policy = "arn:aws:iam::707979055938:role/service-role/codebuild-DefenderTrackerDeploy-service-role"
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