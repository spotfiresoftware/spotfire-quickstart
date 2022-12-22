# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region = "eu-north-1"

  # Note: You could copy your subscription details within the `provider.tf` file respective fields.
  # Nevertheless, we do not recommend defining credential variables here since they could easily be checked into your version control system by mistake.
  //  access_key = "YOUR-ACCESS-KEY"
  //  secret_key = "YOUR-SECRET-KEY"
  //
  //  profile    = "SpotfirePMRole"
  //  assume_role {
  //    role_arn = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
  //    session_name = "SESSION_NAME"
  //    external_id  = "EXTERNAL_ID"
  //  }

  # Much better to use the AWS CLI credentials file
  #shared_credentials_file = "path_file_credentials like ~/.aws/credentials"
}