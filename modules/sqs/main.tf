resource "aws_sqs_queue" "status_update_queue" {
  name                      = "device_status_queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0
  redrive_policy            = jsonencode({
    "deadLetterTargetArn" = "aws_sqs_queue.terraform_queue_deadletter.arn"
    "maxReceiveCount"     = 4
  })

  tags = {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "status_update_queue" {
  name                      = "device_status_queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0
  redrive_policy            = jsonencode({
    "deadLetterTargetArn" = "aws_sqs_queue.terraform_queue_deadletter.arn"
    "maxReceiveCount"     = 4
  })

  tags = {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "position_update_queue" {
  name                      = "device_position_queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy            = jsonencode({
    "deadLetterTargetArn" = "aws_sqs_queue.terraform_queue_deadletter.arn"
    "maxReceiveCount"     = 4
  })

  tags = {
    Environment = "production"
  }
}