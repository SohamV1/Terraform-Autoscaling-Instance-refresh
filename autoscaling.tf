resource "aws_launch_template" "my-lt" {
  name            = "my-launch-template"
  image_id        = "ami-04a81a99f5ec58529"
  instance_type   = "t2.micro"
  key_name        = "key_name"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  user_data       = base64encode(<<EOF
#!/bin/bash
sudo apt update 
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
EOF
  )
}

resource "aws_autoscaling_group" "ag" {
  name                 = "my-ag"
  max_size             = 3
  min_size             = 1
  health_check_type    = "ELB"
  desired_capacity     = 2
  target_group_arns    = [aws_lb_target_group.test.arn]
  launch_template {
    id = aws_launch_template.my-lt.id
    version = aws_launch_template.my-lt.latest_version
  }
  force_delete         = true
  vpc_zone_identifier  = ["subnet-id1", "subnet-id2"]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      skip_matching = true
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "autoscaling-ec2"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_policy" "my-asp" {
  name                   = "my-asp"
  autoscaling_group_name = aws_autoscaling_group.ag.name
  policy_type = "TargetTrackingScaling"


  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 20.0
  }
}