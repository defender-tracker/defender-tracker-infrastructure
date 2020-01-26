output "sns_role_arn" {
  value = aws_iam_role.sns_publish_role.arn
}

output "sns_topic_arn" {
  value = aws_sns_topic.gps_update_topic.arn
}