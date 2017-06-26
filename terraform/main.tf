resource "aws_vpc" "main" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "kafka-cookbook"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "kafka-cookbook IGW"
  }
}

resource "aws_default_route_table" "main" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_security_group" "main" {
  name        = "kafka-cookbook"
  description = "Security group for kafka-cookbook tests"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 0)}"
  map_public_ip_on_launch = true

  tags {
    Name = "kafka-cookbook"
  }
}

resource "aws_key_pair" "main" {
  key_name   = "kafka-cookbook"
  public_key = "${file("~/.ssh/id_rsa_kafka-cookbook.pub")}"
}

output "security_group_id" {
  value = "${aws_security_group.main.id}"
}

output "subnet_id" {
  value = "${aws_subnet.main.id}"
}

output "key_pair_name" {
  value = "${aws_key_pair.main.key_name}"
}
