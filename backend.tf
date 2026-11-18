terraform {
  backend "s3" {
    bucket       = "BUCKET NAME" # add your bucket name here
    key          = "PATH/TO/.tfstate" # specify path to state file
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
