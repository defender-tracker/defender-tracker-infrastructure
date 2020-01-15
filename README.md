# Defender Tracker
The Infrastructure as Code configuration (in Terraform) for the Defender Tracker.

## Summary
This repository contains the Terraform to provision the infrastructure for the online Defender tracking solution. In summary, it receives GPS location updates from an AWS IoT Thing and pushes them into DynamoDB, which is then exposed with an API Gateway to a React App hosted in a static S3 bucket.

## Modules 

### aws_iot_core
Provisions the resources for the AWS IoT Thing to function and push MQTT payloads into DynamoDB.

#### Variables

#### Actions

#### Outputs

### dynamo_db
Provisions the DynamoDB table to store the GPS tracking information.

#### Schema

#### Variables

#### Actions

#### Outputs

