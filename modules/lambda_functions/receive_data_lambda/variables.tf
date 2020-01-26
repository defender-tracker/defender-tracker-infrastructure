variable "dynamodb_table" {
  type = string
  description = "The name of the DynamoDB table which will store the tracking data."
}

variable "naming_prefix" {
  type = string
  description = "The prefix to name the provisioned resources."
}

variable "sns_topic_arn" {
  type = string
  description = "The ARN of the SNS topic to invoke the lambda script."
}

