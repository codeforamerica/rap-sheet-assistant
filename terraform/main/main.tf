# Start with a VPC

resource "aws_vpc" "rap_assist_vpc" {
  tags = {
    Name = "Rap Sheet Assistant VPC"
  }
  cidr_block = "10.0.0.0/16"
}

# Create subnets

resource "aws_subnet" "rap_assist_public" {
  vpc_id     = "${aws_vpc.rap_assist_vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_az1}"

  tags = {
    Name = "Public Subnet 1 (Rap Sheet Assistant)"
  }
}

resource "aws_subnet" "rap_assist_private_1" {
  vpc_id     = "${aws_vpc.rap_assist_vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.aws_az1}"

  tags = {
    Name = "Private Subnet 1 (Rap Sheet Assistant)"
  }
}

resource "aws_subnet" "rap_assist_private_2" {
  vpc_id     = "${aws_vpc.rap_assist_vpc.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "${var.aws_az2}"

  tags = {
    Name = "Private Subnet 2 (Rap Sheet Assistant)"
  }
}

resource "aws_security_group" "elb_security" {
  name = "rap_assist_elb_security"
  vpc_id = "${aws_vpc.rap_assist_vpc.id}"
}

resource "aws_security_group" "bastion_security" {
  name = "bastion_security"
  vpc_id = "${aws_vpc.rap_assist_vpc.id}"

  # SSH access from CfA
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "69.12.169.82/32"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_security_group" "application_security" {
  name = "application_security"
  vpc_id = "${aws_vpc.rap_assist_vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.bastion_security.id}"
    ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.elb_security.id}"
    ]
  }

  # Elastic Beanstalk clock sync
  egress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}


# Give all subnets internet access with default route

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.rap_assist_vpc.id}"

  tags = {
    Name = "Rap Sheet Assistant main gateway"
  }
}

resource "aws_route_table" "internet_access" {
  vpc_id = "${aws_vpc.rap_assist_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags = {
    Name = "Rap Sheet Assistant route to main gateway"
  }
}

resource "aws_route_table_association" "public_internet_access_1" {
  subnet_id = "${aws_subnet.rap_assist_public.id}"
  route_table_id = "${aws_route_table.internet_access.id}"
}

# Place NAT gateways in public subnets

resource "aws_eip" "public_nat_eip_1" {
  vpc = true
  depends_on = [
    "aws_internet_gateway.default"
  ]

  tags = {
    Name = "Rap Sheet Assistant public 1"
  }
}

resource "aws_eip" "public_nat_eip_2" {
  vpc = true
  depends_on = [
    "aws_internet_gateway.default"
  ]

  tags = {
    Name = "Rap Sheet Assistant public 1"
  }
}

resource "aws_nat_gateway" "public_gw_1" {
  allocation_id = "${aws_eip.public_nat_eip_1.id}"
  subnet_id = "${aws_subnet.rap_assist_public.id}"

  depends_on = [
    "aws_internet_gateway.default"
  ]

  tags {
    Name = "NAT"
  }
}

# Route private traffic VIA NAT gateways

resource "aws_route_table" "private_internet_access" {
  vpc_id = "${aws_vpc.rap_assist_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.public_gw_1.id}"
  }
}

resource "aws_route_table_association" "private_internet_access_1" {
  subnet_id = "${aws_subnet.rap_assist_private_1.id}"
  route_table_id = "${aws_route_table.private_internet_access.id}"
}

resource "aws_route_table_association" "private_internet_access_2" {
  subnet_id = "${aws_subnet.rap_assist_private_2.id}"
  route_table_id = "${aws_route_table.private_internet_access.id}"
}

resource "aws_iam_role" "instance_role" {
  name = "instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "beanstalk_role" {
  name = "beanstalk_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eb_enhanced_health" {
  role = "${aws_iam_role.beanstalk_role.name}"
  policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "eb_service" {
  role = "${aws_iam_role.beanstalk_role.name}"
  policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_role_policy_attachment" "worker_tier" {
  role = "${aws_iam_role.instance_role.name}"
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "container" {
  role = "${aws_iam_role.instance_role.name}"
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "web_tier" {
  role = "${aws_iam_role.instance_role.name}"
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "logs_to_cloudwatch" {
  role = "${aws_iam_role.instance_role.name}"
  policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
# unclear if this is necessary if we're not using s3 right now
# resource "aws_iam_role_policy_attachment" "s3_read_write" {
#   role = "${aws_iam_role.instance_role.name}"
#   policy_arn = "${aws_iam_policy.s3_read_write.arn}"
# }

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  role = "${aws_iam_role.instance_role.name}"
}

resource "aws_elastic_beanstalk_application" "rap_assist_beanstalk_application" {
  name = "Rap Sheet Assistant"
}

resource "aws_elastic_beanstalk_environment" "beanstalk_application_environment" {
  name = "rap-assist-${var.environment}"
  application = "${aws_elastic_beanstalk_application.rap_assist_beanstalk_application.name}"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.9.1 running Ruby 2.4 (Puma)"
  tier = "WebServer"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.small"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "${aws_iam_instance_profile.instance_profile.name}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = "${aws_security_group.application_security.id}"
  }

//  setting {
//    namespace = "aws:elb:loadbalancer"
//    name = "SecurityGroups"
//    value = "${aws_security_group.elb_security.id}"
//  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = "${aws_iam_role.beanstalk_role.name}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name = "VPCId"
    value = "${aws_vpc.rap_assist_vpc.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "${aws_subnet.rap_assist_private_1.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "${aws_subnet.rap_assist_public.id}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name = "SystemType"
    value = "enhanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "SECRET_KEY_BASE"
    value = "${var.rails_secret_key_base}"
  }

//  setting {
//    namespace = "aws:elasticbeanstalk:application:environment"
//    name = "RDS_HOST"
//    value = "${aws_db_instance.db.address}"
//  }

//  setting {
//    namespace = "aws:elasticbeanstalk:application:environment"
//    name = "RDS_USERNAME"
//    value = "${var.rds_username}"
//  }
//
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_PASSWORD"
    value = "${random_string.rds_password.result}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name = "ManagedActionsEnabled"
    value = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name = "PreferredStartTime"
    value = "Tue:16:00"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name = "UpdateLevel"
    value = "minor"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name = "InstanceRefreshEnabled"
    value = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name = "StreamLogs"
    value = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name = "DeleteOnTerminate"
    value = "false"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name = "RetentionInDays"
    value = "3653"
  }
}

resource "random_string" "rds_password" {
  length = 30
  special = false
}

resource "aws_db_instance" "db" {
  allocated_storage = 10
  availability_zone = "${var.aws_az1}"
  db_subnet_group_name = "${aws_db_subnet_group.application_db.name}"
  engine = "postgres"
  instance_class = "db.m3.medium"
  kms_key_id = "${aws_kms_key.db_key.arn}"
  name = "autoclearance"
  username = "${var.rds_username}"
  password = "${random_string.rds_password.result}"
  storage_encrypted = true
  storage_type = "gp2"
  vpc_security_group_ids = [
    "${aws_security_group.rds_security.id}"
  ]
}

resource "aws_db_subnet_group" "application_db" {
  name = "application_db"
  subnet_ids = [
    "${aws_subnet.rap_assist_private_1.id}",
    "${aws_subnet.rap_assist_private_2.id}"
  ]
  tags {
    Name = "Rap Assist DB Subnet Group"
  }
}

resource "aws_kms_key" "db_key" {
  description = "rap_assist db key"
}

resource "aws_security_group" "rds_security" {
  name = "rds_security"
  vpc_id = "${aws_vpc.rap_assist_vpc.id}"
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.application_security.id}"
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

