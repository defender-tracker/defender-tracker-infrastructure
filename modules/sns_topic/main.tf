resource "aws_sns_topic" "gps_update_topic" {
  name = "gps_update_topic"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_iam_role" "sns_publish_role" {
  name = "${var.naming_prefix}_sns_publish_role"

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

resource "aws_iam_role_policy" "sns_publish_policy" {
  role = aws_iam_role.sns_publish_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "sns:Publish"
        ],
        "Resource": "${aws_sns_topic.gps_update_topic.arn}"
    }
  ]
}
EOF
}