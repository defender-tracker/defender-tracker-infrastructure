resource "aws_cloudformation_stack" "api_gateway" {
  name = "networking-stack"
  parameters = {
    VPCCidr = "10.0.0.0/16"
  }
  template_body = templatefile("${path.module}/resources/cloudformation_api_gateway_stack.yml", {})
}