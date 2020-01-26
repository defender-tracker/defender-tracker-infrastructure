module "dynamodb_table" {
  source = "./modules/dynamo_db"
  naming_prefix = "duccy_tracker"
}

module "aws_sns_topic" {
  source = "./modules/sns_topic"
  naming_prefix = "duccy_tracker"
}

module "aws_iot_core" {
  source = "./modules/aws_iot_core"
  naming_prefix = "duccy_tracker"
  dynamodb_table_name = module.dynamodb_table.dynamodb_table_name
  mqtt_topic = "defender/gpsupdate"
  sns_role_arn = module.aws_sns_topic.sns_role_arn
  sns_topic_arn = module.aws_sns_topic.sns_topic_arn
}

module "receive_data_lambda_function" {
  source = "./modules/lambda_functions/receive_data_lambda"
  dynamodb_table = module.dynamodb_table.dynamodb_table_name
  sns_topic_arn = module.aws_sns_topic.sns_topic_arn
  naming_prefix = "duccy_tracker"
}
