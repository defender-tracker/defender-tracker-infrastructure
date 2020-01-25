module "dynamodb_table" {
  source = "./modules/dynamo_db"
  naming_prefix = "duccy_tracker"
}

module "aws_iot_core" {
  source = "./modules/aws_iot_core"
  naming_prefix = "duccy_tracker"
  dynamodb_table_name = module.dynamodb_table.dynamodb_table_name
  mqtt_topic = "test/topic"
}