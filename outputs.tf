output "endpoints" {
  value = <<EOF

  NOTE: Post provisioning steps will continue to run even though Terraform has completed
        The log will report 'Complete' when Vault is ready.

  Terraform Version: ${var.vault_license} - ${var.vault_zip_file}

  (Leader) ${var.vault_server_names[0]} (${aws_instance.vault-server[0].public_ip}) | internal: (${aws_instance.vault-server[0].private_ip})
    Tail the log...
      $ ssh -l ubuntu ${aws_instance.vault-server[0].public_ip} -i ~/.ssh/${var.environment_name}.pem tail -f /var/log/tf-user-data.log
    Verify all raft peers...
      $ ssh -l ubuntu ${aws_instance.vault-server[0].public_ip} -i ~/.ssh/${var.environment_name}.pem vault operator raft list-peers
    Your root token...
      $ ssh -l ubuntu ${aws_instance.vault-server[0].public_ip} -i ~/.ssh/${var.environment_name}.pem cat /tmp/key.json|jq .root_token

  (Standby) ${var.vault_server_names[1]} (${aws_instance.vault-server[1].public_ip}) | internal: (${aws_instance.vault-server[1].private_ip})
    Tail the log...
      $ ssh -l ubuntu ${aws_instance.vault-server[1].public_ip} -i ~/.ssh/${var.environment_name}.pem tail -f /var/log/tf-user-data.log

  (Standby) ${var.vault_server_names[2]} (${aws_instance.vault-server[2].public_ip}) | internal: (${aws_instance.vault-server[2].private_ip})
    Tail the log...
      $ ssh -l ubuntu ${aws_instance.vault-server[2].public_ip} -i ~/.ssh/${var.environment_name}.pem tail -f /var/log/tf-user-data.log

  You may need to wait a few minutes for instance registration...
    NLB URL: http://${aws_lb.vault.dns_name}:8200

EOF
}