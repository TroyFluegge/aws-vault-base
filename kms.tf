//--------------------------------------------------------------------
// Vault KMS Auto Unseal Key

resource "aws_kms_key" "vault" {
  description             = "Vault Unseal Key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(var.default_base_tags, {
    Name = "${var.environment_name}-vault-kms-unseal"
  })
}