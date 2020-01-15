resource "aws_dynamodb_table" "gps_dynamodb_table" {
  name           = "${var.naming_prefix}_dynamodb_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "entry_id"
  range_key      = "timestamp"

  attribute {
    name = "entry_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }
}