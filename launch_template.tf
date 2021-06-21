#####  INSTANCE LAUNCH TEMPLATE

resource "aws_launch_template" "launch_template" {
  name                                 = "${var.name}_asg_template"
  #ebs_optimized                        = true
  image_id                             = data.aws_ami.ubuntu.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = aws_subnet.private_A[count.index].id
    security_groups             = aws_security_group.privateSG.id
    delete_on_termination       = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 10
      volume_type ="gp2"
    }
  }
  
  block_device_mappings {
    device_name = "/dev/xvdb"
    ebs {
      volume_size = 10
      volume_type ="gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name          = "${var.name}_asg_template"
    }
  }
  user_data = filebase64("user_data.sh")

  # we don't want to create a new template just because there is a newer AMI
  lifecycle {
    ignore_changes = [
      image_id,
    ]
  }
}


#### Auto Scaling Group


resource "aws_autoscaling_group" "demo_asg" {
  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  desired_capacity     = 4
  min_size = 2
  max_size = 6
  launch_template = {
      id      = "${aws_launch_template.launch_template.id}"
      version = "$$Latest"
    }
  load_balancers       = ["${aws_lb.test.name}"]
  health_check_type    = "ELB"
  
  tag {
    key   = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }

   depends_on = [aws_launch_template.launch_template]
}

