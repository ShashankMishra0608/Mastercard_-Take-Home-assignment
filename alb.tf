###  ELB  ALB
resource "aws_lb" "test" {
  name               = "${var.name}_test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.publicSG.id]
  subnets            = [aws_subnet.public.*.id]
  cross_zone_load_balancing  = true
  enable_deletion_protection = true

health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }

  

  tags = {
    Environment = "${var.name}_demo"
  }
}