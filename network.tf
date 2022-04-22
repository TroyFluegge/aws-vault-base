//--------------------------------------------------------------------
// Network Resources - Creating public and private subnets.
// Using public subnets for Vault example.

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = "${var.environment_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = var.availability_zones
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = merge(var.default_base_tags, {
    Name = "${var.environment_name}-vpc"
  })
}

resource "aws_lb" "vault" {
  name               = "${var.environment_name}-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnets
  
  tags = merge(var.default_base_tags, {
    Name = "${var.environment_name}-lb"
  })
}

resource "aws_lb_target_group" "vault" {
  name        = "${var.environment_name}-lbtg"
  port        = 8200
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/v1/sys/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.default_base_tags, {
    Name = "${var.environment_name}-lbtg"
  })
}

resource "aws_lb_listener" "vault" {
  load_balancer_arn = aws_lb.vault.arn
  port              = "8200"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault.arn
  }
}

resource "aws_lb_target_group_attachment" "vault" {
  count            = length(var.vault_server_names)
  target_group_arn = aws_lb_target_group.vault.arn
  target_id        = aws_instance.vault-server[count.index].id
  port             = 8200
}