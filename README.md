# Create a Vault HA cluster on AWS using Terraform

Based on https://github.com/hashicorp/vault-guides/tree/master/operations/raft-storage/aws

These assets are provided to perform the tasks described in the [Vault HA Cluster with Integrated Storage on AWS](https://learn.hashicorp.com/vault/operations/raft-storage-aws) guide.

---

1.  Set your AWS credentials as environment variables:

    ```plaintext
    $ export AWS_ACCESS_KEY_ID = "<YOUR_AWS_ACCESS_KEY_ID>"
    $ export AWS_SECRET_ACCESS_KEY = "<YOUR_AWS_SECRET_ACCESS_KEY>"
    ```

1.  Use the provided `terraform.tfvars.example` as a base.

    Example:

    ```shell
    # AWS Region
    aws_region = "us-east-2"

    # List of AZ's for HA nodes
    availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
    
    # Prefix name for all resources created
    environment_name = "vault-demo"
    
    # Base tags for all resources
    default_base_tags = {
      owner   = "FirstName LastName"
      contact = "me@mydomain.com"
    }
    
    # Optional Vault binary download URL - Default is v.1.10.0 OSS
    vault_zip_file = "https://releases.hashicorp.com/vault/1.10.0+ent/vault_1.10.0+ent_linux_amd64.zip"
    
    # Optional Vault autoload license - Default is oss
    vault_license = "license.hclic"
    ```

1.  Run Terraform commands to provision your cloud resources:

    ```plaintext
    $ terraform init

    $ terraform plan

    $ terraform apply -auto-approve
    ```

    The Terraform output will display the IP addresses of the provisioned Vault nodes and load balancer URL.

    Example:

    ```plaintext
    NOTE: Post provisioning steps will continue to run even though Terraform has completed
          The log will report 'Complete' when Vault is ready.

    Terraform Version: vault.hclic - https://releases.hashicorp.com/vault/1.10.0+ent/vault_1.10.0+ent_linux_amd64.zip

    (Leader) node_1 (18.117.168.75) | internal: (10.0.1.10)
      Tail the log...
        $ ssh -l ubuntu 18.117.168.75 -i ~/.ssh/vault-demo.pem tail -f /var/log/tf-user-data.log
      Verify all raft peers...
        $ ssh -l ubuntu 18.117.168.75 -i ~/.ssh/vault-demo.pem vault operator raft list-peers
      Your root token...
        $ ssh -l ubuntu 18.117.168.75 -i ~/.ssh/vault-demo.pem cat /tmp/key.json|jq .root_token

    (Standby) node_2 (18.188.131.30) | internal: (10.0.2.10)
      Tail the log...
        $ ssh -l ubuntu 18.188.131.30 -i ~/.ssh/vault-demo.pem tail -f /var/log/tf-user-data.log

    (Standby) node_3 (3.138.107.179) | internal: (10.0.3.10)
      Tail the log...
        $ ssh -l ubuntu 3.138.107.179 -i ~/.ssh/vault-demo.pem tail -f /var/log/tf-user-data.log

    You may need to wait a few minutes for instance registration...
      NLB URL: http://vault-demo-lb-b9d7a60d49090976.elb.us-east-2.amazonaws.com:8200
    ```

# Clean up the cloud resources

When you are done exploring, execute the `terraform destroy` command to terminal all AWS elements:

```plaintext
$ terraform destroy -auto-approve
```