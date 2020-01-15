module "dynamodb_table" {
  source = "./modules/dynamo_db"
  naming_prefix = "defender_tracker"
}

module "aws_iot_core" {
  source = "./modules/aws_iot_core"
  naming_prefix = "defender_tracker"
  dynamodb_table_name = module.dynamodb_table.dynamo_db_table_name
  mqtt_topic = "test/topic"
}