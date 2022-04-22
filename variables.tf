# AWS region and AZs in which to deploy
variable "aws_region" {
  default = "us-east-1"
}

variable "availability_zones" {
 default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# All resources will be tagged with this
variable "environment_name" {
  default = "vault-demo"
}

variable "vault_server_names" {
  description = "Names of the Vault nodes that will join the cluster"
  type        = list(string)
  default     = ["vault_1", "vault_2", "vault_3"]
}

# Enterprise license.  Leave the default 'oss' value for opensource
# Setting this to a nonexistent file will default to 'oss'
variable "vault_license" {
  description = "The Enterprise license key."
  default = "oss"
}

variable "vault_server_private_ips" {
  description = "The private ips of the Vault nodes that will join the cluster"
  # @see https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html
  type    = list(string)
  default = ["10.0.1.10", "10.0.2.10", "10.0.3.10"]
}

# URL for Vault binary. Default to OSS
variable "vault_zip_file" {
  default = "https://releases.hashicorp.com/vault/1.10.0/vault_1.10.0_linux_amd64.zip"
}

# Instance size
variable "instance_type" {
  default = "t2.micro"
}

# Standand Resources Tags
variable "default_base_tags" {
  description = "Required tags for the environment"
  type        = map(string)
}
