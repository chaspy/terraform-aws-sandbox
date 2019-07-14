provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "chaspy_test_lc" {
  name          = "test_config"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t3.nano"
}

resource "aws_autoscaling_group" "chaspy_test_asg" {
  availability_zones   = ["ap-northeast-1d"]
  name                 = "chaspy-test-asg"
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
  launch_configuration = "${aws_launch_configuration.chaspy_test_lc.name}"

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
