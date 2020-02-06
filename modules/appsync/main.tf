##
## DynamoDB Tables
##

resource "aws_dynamodb_table" "device_configuration" {
  name           = "device_configuration"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "device_id"

  attribute {
    name = "device_id"
    type = "S"
  }
}

##
## IAM Roles and Policies
##

resource "aws_iam_role" "example" {
  name = "example"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "appsync.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "example" {
  name = "example"
  role = "${aws_iam_role.example.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_dynamodb_table.example.arn}"
      ]
    }
  ]
}
EOF
}

##
## AppSync Datasources
##

resource "aws_appsync_datasource" "example" {
  api_id           = "${aws_appsync_graphql_api.device_configuration.id}"
  name             = "device_configuration"
  service_role_arn = "${aws_iam_role.device_configuration.arn}"
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = "${aws_dynamodb_table.example.name}"
  }
}

resource "aws_appsync_datasource" "device_configuration" {
  api_id = "${aws_appsync_graphql_api.test.id}"
  name   = "tf_example"
  type   = "HTTP"

  http_config {
    endpoint = "http://example.com"
  }
}

##
## AppSync APIs
##

resource "aws_appsync_graphql_api" "tracker" {
  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  name                = "tracker"

  user_pool_config {
    aws_region     = "${data.aws_region.current.name}"
    default_action = "ALLOW"
    user_pool_id   = "${aws_cognito_user_pool.tracker.id}"
  }

  schema = "${var.schema}"
}

##
## AppSync Function
##

resource "aws_appsync_function" "check_ownership" {
  api_id                    = "${aws_appsync_graphql_api.test.id}"
  data_source               = "${aws_appsync_datasource.test.name}"
  name                      = "tf_example"
  request_mapping_template  = <<EOF
#set($expression = "#identity = :identity")
#set($expressionNames = { "#identity" : "owner" })
#set($expressionValues = { ":identity" : { "S": "$context.identity.sub" }})
#if($context.args.filter.device_id)
  #set($expression = "${expression} AND #device_id = :device_id")
  $util.qr($expressionNames.put( "#device_id", "device_id" ))
  $util.qr($expressionValues.put( ":device_id", {"S": "$context.args.filter.device_id.eq"} ))
#end

{
	"version" : "2017-02-28",
	"operation" : "Scan",
    "filter":{
        "expression": "$expression",
        "expressionNames": $utils.toJson($expressionNames),
        "expressionValues": $utils.toJson($expressionValues)
    }
}
EOF
  response_mapping_template = <<EOF
## Raise a GraphQL field error in case of a datasource invocation error
#if($ctx.error)
    $util.error($ctx.error.message, $ctx.error.type)
#end
## Pass back the result from DynamoDB. **
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_function" "get_permitted_updates" {
  api_id                    = "${aws_appsync_graphql_api.test.id}"
  data_source               = "${aws_appsync_datasource.test.name}"
  name                      = "tf_example"
  request_mapping_template  = <<EOF
#if($ctx.prev.result.items.size() == 0) 
  #return({"items":[]})
#end

#set($expression = "")
#set($expressionValues = {})
#foreach($item in $context.prev.result.items)
    #set( $expression = "${expression} contains(device_id, :var$foreach.count )" )
    #set( $val = {})
    #set( $test = $val.put("S", $item.device_id))
    #set( $values = $expressionValues.put(":var$foreach.count", $val))
    #if ( $foreach.hasNext )
    #set( $expression = "${expression} OR" )
    #end
#end
{
    "version" : "2017-02-28",
    "operation" : "Scan",
    "filter":{
        "expression": "$expression",
        "expressionValues": $utils.toJson($expressionValues)
    }
}
EOF
  response_mapping_template = <<EOF
## Raise a GraphQL field error in case of a datasource invocation error
#if($ctx.error)
    $util.error($ctx.error.message, $ctx.error.type)
#end
## Pass back the result from DynamoDB. **
$util.toJson($ctx.result)
EOF
}


##
## AppSync API Resolver
##

resource "aws_appsync_resolver" "create_device" {
  api_id      = "${aws_appsync_graphql_api.tracker.id}"
  field       = "device_id"
  type        = "Query"
  data_source = "${aws_appsync_datasource.device_configuration.name}"

  request_template = <<EOF
{
    "version" : "2017-02-28",
    "operation" : "PutItem",
    "key" : {
        "device_id" : $util.dynamodb.toDynamoDBJson($util.autoId())
    },
    "attributeValues" : {
    	"name" : { "S" : "${context.args.input.name}" },
      "owner": { "S" : "${context.identity.sub}" }
    }
}
EOF

  response_template = <<EOF
#if($ctx.result.statusCode == 200)
    $util.toJson($context.result)
#else
    $util.toJson($utils.appendError($ctx.result.body, $ctx.result.statusCode))
#end
EOF
}

resource "aws_appsync_resolver" "Mutation_pipelineTest" {
  type              = "Mutation"
  api_id            = "${aws_appsync_graphql_api.test.id}"
  field             = "pipelineTest"
  request_template  = "{}"
  response_template = "$util.toJson($ctx.result)"
  kind              = "PIPELINE"
  pipeline_config {
    functions = [
      "${aws_appsync_function.test1.function_id}",
      "${aws_appsync_function.test2.function_id}",
      "${aws_appsync_function.test3.function_id}"
    ]
  }
}
