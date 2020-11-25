# Specify the provider and access details
  provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "tf_test_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags ={
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "tf_test_subnet" {
  vpc_id                  = "${aws_vpc.tf_test_vpc.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags ={
    Name = "${var.subnet_name}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.tf_test_vpc.id}"

  tags ={
    Name = "${var.IG_name}"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.tf_test_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags ={
    Name = "${var.routetable_name}"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.tf_test_subnet.id}"
  route_table_id = "${aws_route_table.r.id}"
}

# Instance security group to access the instances over SSH
resource "aws_security_group" "default" {
  name        = "${var.sg_name}"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.tf_test_vpc.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Elb security group to access the ELB over HTTP
resource "aws_security_group" "elb" {
  name        = "${var.elbsg_name}"
  description = "Used in the terraform"

  vpc_id = "${aws_vpc.tf_test_vpc.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_elb" "web" {
  name = "${var.elb_name}"

  # The same availability zone as our instance
  subnets = ["${aws_subnet.tf_test_subnet.id}"]

  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

resource "aws_lb_cookie_stickiness_policy" "default" {
  name                     = "lbpolicy"
  load_balancer            = "${aws_elb.web.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}


resource "aws_launch_configuration" "lc" {
  image_id             = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.key_name}"
  security_groups      = ["${aws_security_group.default.id}"]
  user_data            = "${file("userdata.sh")}"
}

resource "aws_autoscaling_group" "asg" {
  name = "${aws_launch_configuration.lc.name}"
  launch_configuration      = "${aws_launch_configuration.lc.id}"
  vpc_zone_identifier       = ["${aws_subnet.tf_test_subnet.id}"]
  load_balancers            = ["${aws_elb.web.name}"]
  health_check_type         = "${var.health_check_type}"
  health_check_grace_period = "${var.health_check_grace_period}"
  min_size                  = "${var.asg_min}"
  max_size                  = "${var.asg_max}"
  wait_for_elb_capacity     = "${var.asg_min}"
  desired_capacity          = "${var.asg_min}"

  tag {
    key                 = "Name"
    value               = "${var.instance_name}"
    propagate_at_launch = "true"
  }
}