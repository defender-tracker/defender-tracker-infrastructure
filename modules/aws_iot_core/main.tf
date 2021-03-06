resource "aws_iot_thing" "tracker" {
  name = "${var.naming_prefix}_iot_thing"
}

resource "aws_iot_certificate" "defender_tracker_cert" {
  active = true
}

resource "aws_iot_policy" "defender_tracker_iot_policy" {
  name = "${var.naming_prefix}_iot_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iot:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iot_policy_attachment" "att" {
  policy = aws_iot_policy.defender_tracker_iot_policy.name
  target = aws_iot_certificate.defender_tracker_cert.arn
}

resource "aws_iot_thing_principal_attachment" "att" {
  principal = aws_iot_certificate.defender_tracker_cert.arn
  thing     = aws_iot_thing.tracker.name
}

resource "aws_iot_topic_rule" "rule" {
  name        = "${var.naming_prefix}_update_rule"
  description = "Upon receiving an update from the thing, this rule adds it to the defined DynamoDB."
  enabled     = true
  sql         = "SELECT * FROM '${var.mqtt_topic}'"
  sql_version = "2015-10-08"

}

resource "aws_iam_role" "tracker_role" {
  name = "${var.naming_prefix}_db_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_dynamodb_table" "dynamo_db_table" {
  name = var.dynamodb_table_name
}

resource "aws_iam_role_policy" "iam_policy_for_lambda" {
  name = "${var.naming_prefix}_db_policy"
  role = aws_iam_role.tracker_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "sns:Publish"
        ],
        "Resource": "${data.aws_dynamodb_table.dynamo_db_table.arn}"
    }
  ]
}
EOF
}