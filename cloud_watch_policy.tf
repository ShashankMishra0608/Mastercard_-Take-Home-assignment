# *******************
# scale up alarm +1
# *******************
 
 
resource "aws_autoscaling_policy" "asg-cpu-policy" {
  name                   = "asg-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.demo_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
 
 
  # cooldown: this period is waiting time for ec2 instance to catch the cloudwatch metrics
  cooldown               = "300"
 
  policy_type            = "SimpleScaling"
}
 
 
 
 
# *******************
# scale down alarm -1
# *******************
 
 
resource "aws_autoscaling_policy" "asg-cpu-policy-scaledown" {
  name                   = "asg-cpu-policy-scaledown"
  autoscaling_group_name =  aws_autoscaling_group.demo_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
 
  # cooldown: this period is waiting time for ec2 instance to catch the cloudwatch metrics
  cooldown               = "300"
 
  policy_type            = "SimpleScaling"
}
 
 
 
 
# *************************************
# cloudwatch CPU utilization condition + 1
#
# notice that we used: "asg-cpu-policy"
# which is basically very first definition
# within this configuration file. It means
# that we if CPU utilization as the agerage
# of two checks utilization
# will increase in 30% compared to the average
# CPU utilization and check perion between
# this two checks is 120 seconds please add
# one more instance (server)
#
# *************************************
 
 
resource "aws_cloudwatch_metric_alarm" "asg-cpu-alarm" {
  alarm_name          = "asg-cpu-alarm"
  alarm_description   = "asg-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
 
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.demo_asg.name
  }
 
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.asg-cpu-policy.arn}"]
}
 
 
 
# *************************************
# cloudwatch CPU utilization condition - 1
#
# notice that we used: "asg-cpu-policy-scaledown"
# which is basically very first definition
# within this configuration file. It means
# that we if CPU utilization as the agerage
# of two checks CPU utilization
# will decrease in 5% compared to the average
# CPU utilization and check perion between
# this two checks is 120 seconds please remove
# one more instance (server)
#
# *************************************
 
 
 
resource "aws_cloudwatch_metric_alarm" "asg-cpu-alarm-scaledown" {
  alarm_name          = "asg-cpu-alarm-scaledown"
  alarm_description   = "asg-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5"
 
  dimensions = {
    "AutoScalingGroupName" =  aws_autoscaling_group.demo_asg.name
  }
 
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.asg-cpu-policy-scaledown.arn}"]
}


# resource "aws_autoscaling_policy" "web_policy_up" {
#   name = "web_policy_up"
#   scaling_adjustment = 1
#   adjustment_type = "ChangeInCapacity"
#   cooldown = 300
#   autoscaling_group_name = aws_autoscaling_group.web.name
# }

# resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
#   alarm_name = "web_cpu_alarm_up"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods = "2"
#   metric_name = "CPUUtilization"
#   namespace = "AWS/EC2"
#   period = "120"
#   statistic = "Average"
#   threshold = "60"

#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.web.name
#   }

#   alarm_description = "This metric monitor EC2 instance CPU utilization"
#   alarm_actions = [ aws_autoscaling_policy.web_policy_up.arn ]
# }

# resource "aws_autoscaling_policy" "web_policy_down" {
#   name = "web_policy_down"
#   scaling_adjustment = -1
#   adjustment_type = "ChangeInCapacity"
#   cooldown = 300
#   autoscaling_group_name = aws_autoscaling_group.web.name
# }

# resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
#   alarm_name = "web_cpu_alarm_down"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods = "2"
#   metric_name = "CPUUtilization"
#   namespace = "AWS/EC2"
#   period = "120"
#   statistic = "Average"
#   threshold = "10"

#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.web.name
#   }

#   alarm_description = "This metric monitor EC2 instance CPU utilization"
#   alarm_actions = [ aws_autoscaling_policy.web_policy_down.arn ]
# }