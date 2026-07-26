module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
module ec2_instance {
  source  = "terraform-aws-modules/ec2-instance/aws"

  for_each = toset(["one", "two", "three"])

  name = "instance-${each.key}"

  instance_type = "t3.micro"
  key_name      = "user1"
  monitoring    = true
  subnet_id     = "subnet-eddcdzz4"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
module security_group {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bishal_security_group"
  description = "these security group controls the inbound and outboound traffic rules"
  vpc_id      = "vpc-12345678"

  ingress_rules = {
    https = {
      from_port    = 443
      to_port      = 443
      ip_protocol  = "tcp"
      cidr_ipv4    = "10.0.0.0/16"
      description  = "HTTPS inbound traffic"
    }
    "self-all" = {
      ip_protocol                  = "-1"
      referenced_security_group_id = "self"
      description                  = "All traffic from members of this SG"
    }
  }

  egress_rules = {
    all = {

      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = {
    Environment = "dev"
  }
}
module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "example"
  path        = "/"
  description = "My example policy"

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "ec2:Describe*"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    }
  EOF

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
module "s3_bucket_for_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "my-application-logs"

  # Allow deletion of non-empty bucket
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_elb_log_delivery_policy = true  # Required for ALB logs
  attach_lb_log_delivery_policy  = true  # Required for ALB/NLB logs
}
module "metric_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 3.0"

  alarm_name          = "an alarm for an error or exception behaviour in application logs"
  alarm_description   = "Bad errors in my-application-logs"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 10
  period              = 60
  unit                = "Count"

  namespace   = "MyApplication"
  metric_name = "ErrorCount"
  statistic   = "Maximum"

  alarm_actions = ["arn:aws:sns:eu-west-1:835367859852:my-sns-queue"]
}