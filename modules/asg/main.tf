data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "instance_role" {
  name = "asg-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "instance_policy" {
  name        = "asg-instance-policy"
  description = "Policy for ASG instances"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ],
        Resource = [
          "arn:aws:s3:::aws-3-tier-project-application-code",
          "arn:aws:s3:::aws-3-tier-project-application-code/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory"
        ],
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/myapp/secrets/private/ec2-instance-key"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.instance_policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "asg-instance-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_launch_template" "web_server_lt" {
  name          = "${var.project_name}-web-server-lt"
  image_id      = var.ami
  instance_type = var.cpu
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }
  user_data = base64encode(templatefile("./modules/asg/webserver.sh", {
    bucket_name      = var.bucket_name,
    internal_alb_dns = var.internal_alb_dns
  }))

  vpc_security_group_ids = [var.web_tier_sg_id]

  tags = {
    Name = "${var.project_name}-web-server-lt"
  }
}
resource "aws_autoscaling_group" "web_server_asg" {
  name                      = "${var.project_name}-web-server-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_cap
  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type
  vpc_zone_identifier       = [var.pub_sub_1a_id, var.pub_sub_2b_id]
  target_group_arns         = [var.web_tier_tg_arn]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.web_server_lt.id
    version = aws_launch_template.web_server_lt.latest_version
  }
}

resource "aws_launch_template" "app_server_lt" {
  name          = "${var.project_name}-app-server-lt"
  image_id      = var.ami
  instance_type = var.cpu
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }
  user_data = base64encode(templatefile("./modules/asg/appserver.sh", {
    db_host     = var.db_host,
    db_port     = var.db_port,
    db_user     = var.db_user,
    db_password = var.db_password,
    db_name     = var.db_name,
    server_port = var.server_port,
    bucket_name = var.bucket_name,
    db_file     = filebase64(var.db_file)
  }))

  vpc_security_group_ids = [var.app_tier_sg_id]

  tags = {
    Name = "${var.project_name}-app-server-lt"
  }
}
resource "aws_autoscaling_group" "app_server_asg" {
  name                      = "${var.project_name}-app-server-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_cap
  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type
  vpc_zone_identifier       = [var.pri_sub_3a_id, var.pri_sub_4b_id]
  target_group_arns         = [var.app_tier_tg_arn]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.app_server_lt.id
    version = aws_launch_template.app_server_lt.latest_version
  }

  depends_on = [var.rds_aurora_cluster_instance]
}

variable "autoscaling_groups" {
  type    = list(string)
  default = ["web-server-asg", "app-server-asg"]
}

# scale up policy
resource "aws_autoscaling_policy" "scale_up" {
  for_each = toset(var.autoscaling_groups)

  name                   = "${each.value}-scale-up"
  autoscaling_group_name = "${var.project_name}-${each.value}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"

  depends_on = [aws_autoscaling_group.web_server_asg, aws_autoscaling_group.app_server_asg]
}

# scale up alarm
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  for_each = toset(var.autoscaling_groups)

  alarm_name          = "${each.value}-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70" # New instance will be created once CPU utilization is higher than 70 %
  dimensions = {
    "AutoScalingGroupName" = "${var.project_name}-${each.value}"
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up[each.key].arn]

  depends_on = [aws_autoscaling_group.web_server_asg, aws_autoscaling_group.app_server_asg]
}

# scale down policy
resource "aws_autoscaling_policy" "scale_down" {
  for_each = toset(var.autoscaling_groups)

  name                   = "${each.value}-scale-down"
  autoscaling_group_name = "${var.project_name}-${each.value}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"

  depends_on = [aws_autoscaling_group.web_server_asg, aws_autoscaling_group.app_server_asg]
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  for_each = toset(var.autoscaling_groups)

  alarm_name          = "${each.value}-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5" # Instance will scale down when CPU utilization is lower than 5 %
  dimensions = {
    "AutoScalingGroupName" = "${var.project_name}-${each.value}"
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down[each.key].arn]

  depends_on = [aws_autoscaling_group.web_server_asg, aws_autoscaling_group.app_server_asg]
}