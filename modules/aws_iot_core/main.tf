resource "aws_iot_thing" "tracker" {
  name = "${var.naming_prefix}_iot_thing"
}

resource "aws_iot_certificate" "defender_tracker_cert" {
  active = true
}

resource "aws_iot_policy" "tracker_device_iot_policy" {
  name = "${var.naming_prefix}_iot_policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iot:Connect"
            ],
            "Resource": [
                "arn:aws:iot:eu-west-2:707979055938:client/$${iot:Connection.Thing.ThingName}""
            ],
            "Condition": {
                "Bool": {
                    "iot:Connection.Thing.IsAttached": ["true"]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iot:Publish"
            ],
            "Resource": [
                "arn:aws:iot:eu-west-2:707979055938:topic/$aws/things/$${iot:Connection.Thing.ThingName}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iot:Subscribe"
            ],
            "Resource": [
                "arn:aws:iot:eu-west-2:707979055938:topicfilter/$aws/things/$${iot:Connection.Thing.ThingName}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iot:Receive"
            ],
            "Resource": [
                "arn:aws:iot:eu-west-2:707979055938:topic/$aws/things/$${iot:Connection.Thing.ThingName}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iot:GetThingShadow"
            ],
            "Resource": [
                "arn:aws:iot:us-east-1:123456789012:thing/$${iot:Connection.Thing.ThingName}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iot:UpdateThingShadow"
            ],
            "Resource": [
                "arn:aws:iot:us-east-1:123456789012:thing/$${iot:Connection.Thing.ThingName}"
            ]
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
  sql         = "SELECT * as data, topic() as topic FROM '+/transit'"
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