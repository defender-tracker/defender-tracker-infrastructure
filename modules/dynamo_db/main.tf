resource "aws_dynamodb_table" "gps_dynamodb_table" {
  name           = "${var.naming_prefix}_dynamodb_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "device_id"
  range_key      = "epoch_time"

  attribute {
    name = "device_id"
    type = "S"
  }

  attribute {
    name = "epoch_time"
    type = "N"
  }
}