variable "naming_prefix" {
  type = string
  description = "The prefix to name the provisioned resources."
}

variable "dynamodb_table_name" {
  type = string
  description = "The name of the DynamoDB table to push the data to."
}

variable "mqtt_topic" {
  type = string
  description = "The topic to which the thing publishes data."
}


variable "sns_topic_arn" {
  type = string
  description = "The SNS topic to send the data from the IoT Thing."
}

variable "sns_role_arn" {
  type = string
  description = "The role which has permission to send the data to the SNS Topic."
}



