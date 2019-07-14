provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_autoscaling_group" "chaspy_test_asg" {
  availability_zones   = ["ap-northeast-1"]
  name                 = "chaspy-test-asg"
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]

  max_size             = 10
  min_size             = 1

  tag {
    key                 = "Foo"
    value               = "foo-bar"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_lifecycle_hook" "chaspy_test_hook" {
  name                   = "chaspy-test-hook"
  autoscaling_group_name = "${aws_autoscaling_group.chaspy_test_asg.name}"
  default_result         = "CONTINUE"
  heartbeat_timeout      = 2000
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"

  notification_metadata = <<EOF
{
  "foo": "bar"
}
EOF

#  notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
#  role_arn                = "arn:aws:iam::123456789012:role/S3Access"
}
