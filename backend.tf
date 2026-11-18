terraform {
  backend "s3" {
    bucket       = "terraform-state-storage-vpc-demo"
    key          = "dev/vpc-peering.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}