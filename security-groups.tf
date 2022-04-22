//--------------------------------------------------------------------
// Network Security Groups
// Using your external IP for inbound access
// May not work depending on our egress

data "external" "myip" {
  program = ["curl", "http://ipinfo.io"]
}

resource "aws_security_group" "vault-sg" {
  name        = "${var.environment_name}-sg"
  description = "SSH and Internal Traffic"
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.default_base_tags, {
    Name = "${var.environment_name}-sg"
  })

  # SSH - Administrative
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.external.myip.result.ip}/32"]
  }

  # Vault API traffic
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["${data.external.myip.result.ip}/32"]
  }

  # Vault cluster traffic
  ingress {
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    cidr_blocks      = ["${data.external.myip.result.ip}/32"]
  }

  # Internal Traffic
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}