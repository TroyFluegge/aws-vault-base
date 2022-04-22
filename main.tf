provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "vault" {
  algorithm = "RSA"
}

resource "aws_key_pair" "vault" {
  key_name   = var.environment_name
  public_key = tls_private_key.vault.public_key_openssh
}

resource "null_resource" "vault" {
  provisioner "local-exec" {
    command = "echo '${tls_private_key.vault.private_key_pem}' > ~/.ssh/${var.environment_name}.pem && chmod 600 ~/.ssh/${var.environment_name}.pem"
  }
}

locals {
  vault_license_blob = fileexists(var.vault_license) ? file(var.vault_license) : "oss"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

//--------------------------------------------------------------------
// Vault Server Instances

resource "aws_instance" "vault-server" {
  count                       = length(var.vault_server_names)
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  availability_zone           = var.availability_zones[count.index]
  subnet_id                   = module.vpc.public_subnets[count.index]
  key_name                    = var.environment_name
  vpc_security_group_ids      = [aws_security_group.vault-sg.id]
  associate_public_ip_address = true
  private_ip                  = var.vault_server_private_ips[count.index]
  iam_instance_profile        = aws_iam_instance_profile.vault-server.id
  tags = merge(var.default_base_tags, {
    Name = "${var.environment_name}-${var.vault_server_names[count.index]}"
  })

  user_data = templatefile("${path.module}/templates/userdata-vault-server.tpl", {
    tpl_vault_count_index        = count.index,
    tpl_vault_active_node        = var.vault_server_names[0],
    tpl_vault_node_name          = var.vault_server_names[count.index],
    tpl_vault_storage_path       = "/vault/${var.vault_server_names[count.index]}",
    tpl_vault_zip_file           = var.vault_zip_file,
    tpl_vault_service_name       = "vault-${var.environment_name}",
    tpl_vault_kms_unseal_key     = aws_kms_key.vault.id,
    tpl_vault_aws_region         = var.aws_region,
    tpl_vault_node_address_names = zipmap(var.vault_server_private_ips, var.vault_server_names)
    tpl_vault_license            = var.vault_license
    tpl_vault_license_blob       = local.vault_license_blob
  })

  lifecycle {
    ignore_changes = [ami, tags]
  }
}