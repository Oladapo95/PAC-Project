terraform {
  backend "s3" {
    bucket         = "pacpet1-state-bucket-d"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "pacpet1_dynamo_table"
    encrypt        = true
    #Need to specify profile here, dumb but it works
    profile = "personal"
  }
}