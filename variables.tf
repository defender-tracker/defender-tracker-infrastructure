variable "aws_iot_certificate_arn" {
  type = string
  description = "The ARN of the AWS IOT Certificate used for the MQTT device."
}

variable "naming_prefix" {
  type = string
  description = "The prefix to name the provisioned resources."
  default = "tracker"
}

