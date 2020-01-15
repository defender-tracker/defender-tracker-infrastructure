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

