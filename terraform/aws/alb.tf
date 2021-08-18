#----------------------------------------
# Application Load Balancer
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html
#----------------------------------------

resource "aws_security_group" "web-alb" {
  name        = "${var.prefix}-spotfire-web-alb-sg"
  description = "Spotfire web LB security group"
  vpc_id      = aws_vpc.this.id

  //  ingress {
  //    from_port   = 443
  //    to_port     = 443
  //    protocol    = "tcp"
  //    cidr_blocks = var.allowed_cidr_blocks
  //  }
  ingress {
    description = "Allow inbound HTTP from web addresses"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.web_address_prefixes
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-spotfire-web-alb-sg"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_alb" "web" {
  name            = "${var.prefix}-spotfire-web-alb"
  security_groups = [aws_security_group.web-alb.id]
  subnets         = aws_subnet.public.*.id

  tags = {
    Name = "${var.prefix}-spotfire-web-alb"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_alb_target_group" "web" {
  name     = "${var.prefix}-spotfire-web-alb-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/spotfire/login.html"
    port = 8080
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.web.arn
    type             = "forward"
  }
}

//variable "certificate_arn" {
//  default = ""
//}
//resource "aws_alb_listener" "listener_https" {
//  load_balancer_arn = aws_alb.web.arn
//  port              = "443"
//  protocol          = "HTTPS"
//  ssl_policy        = "ELBSecurityPolicy-2016-08"
//  certificate_arn   = var.certificate_arn
//  default_action {
//    target_group_arn = aws_alb_target_group.web.arn
//    type             = "forward"
//  }
//}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_alb_target_group_attachment" "tss" {
  depends_on = [aws_instance.tss]

  //  for_each         = toset(aws_instance.tss.*.id)
  count            = var.tss_instances
  target_group_arn = aws_alb_target_group.web.arn
  target_id        = element(aws_instance.tss.*.id, count.index)
  //  target_id        = each.key
  port = 8080
}

output "aws_alb_dns_name" {
  value = aws_alb.web.dns_name
}