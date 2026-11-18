variable "vpc_cidrs" {
  description = "cidr blocks of vpcs"
  type        = list(string)

  validation {
    condition     = length(var.vpc_cidrs) == 2
    error_message = "provide exactly two VPC CIDR blocks"
  }
}

variable "subnet_cidrs" {
  description = "cidr blocks of subnets"
  type        = list(string)

  validation {
    condition     = length(var.subnet_cidrs) == 2
    error_message = "Provide at least two subnet CIDR blocks"
  }
}

variable "ssh_allowed_cidr" {
  description = "Your public IP address in CIDR notation, allowed to SSH into both instances"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_allowed_cidr))
    error_message = "Provide a valid IPv4 CIDR, such as 203.0.113.10/32."
  }
}

variable "primary_public_key_path" {
  description = "Path to primary region SSH public key"
  type        = string
}

variable "secondary_public_key_path" {
  description = "Path to secondary region SSH public key"
  type        = string
}

variable "primary_region" {
  description = "region of primary vpc"
  type        = string
}

variable "secondary_region" {
  description = "region of secondary vpc"
  type        = string
}

variable "all_traffic" {
  description = "all traffic cidr"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}