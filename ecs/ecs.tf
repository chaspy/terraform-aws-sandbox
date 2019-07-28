provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_ecs_cluster" "foo" {
  name = "white-hart"
}
