data "aws_region" "current" {}

data "aws_dynamodb_table" "tracker_dynamodb_table" {
  name = var.dynamodb_table
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "receive_data_lambda_role" {
  name = "${var.naming_prefix}_receive_data_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowLambdaAssumeRole",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "receive_data_lambda_policy" {
  name = "${var.naming_prefix}_receive_data_lambda_policy"
  role = aws_iam_role.receive_data_lambda_role.id
  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"AllowDynamoPutItem",
         "Action":[
            "dynamodb:PutItem",
            "dynamodb:UpdateItem"
         ],
         "Effect":"Allow",
         "Resource":"${data.aws_dynamodb_table.tracker_dynamodb_table.arn}"
      },
      {
         "Sid":"AllowLambdaCreateLogGroup",
         "Action":[
            "logs:CreateLogGroup"
         ],
         "Effect":"Allow",
         "Resource":"arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
         "Sid":"AllowLambdaPushLogs",
         "Action":[
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Effect":"Allow",
         "Resource":"arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.naming_prefix}_receive_data_lambda:*"
      }
   ]
}
  EOF
}

resource "aws_lambda_function" "receive_data_lambda" {
  filename      = "${path.root}/resources/lambda_code/receive_data_lambda.zip"
  source_code_hash = filebase64sha256("${path.root}/resources/lambda_code/receive_data_lambda.zip")
  function_name = "${var.naming_prefix}_receive_data_lambda"
  role          = aws_iam_role.receive_data_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.7"

  environment {
    variables = {
      region = data.aws_region.current.name,
      dynamodb_table = var.dynamodb_table
    }
  }
}

resource "aws_lambda_permission" "invoke_from_sns" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.receive_data_lambda.function_name
  principal = "sns.amazonaws.com"
  source_arn = var.sns_topic_arn
}

resource "aws_sns_topic_subscription" "gps_update_invocation" {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.receive_data_lambda.arn
}