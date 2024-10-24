module "jenkins" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-tf"

  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-0c76aed609a9d7308"]
  subnet_id              = "subnet-0d0d98dc2ce27610f"
  ami                    = data.aws_ami.ami_info.id
  user_data              = file("jenkins.sh")
  tags = {
    Name = "jenkins-tf"
  }
}


module "jenkins-agent" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-agent"

  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-0c76aed609a9d7308"]
  subnet_id              = "subnet-0d0d98dc2ce27610f"
  ami                    = data.aws_ami.ami_info.id
  user_data              = file("jenkins-agent.sh")
  tags = {
    Name = "jenkins-agent"
  }

}


module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name = "jenkins"
      type = "A"
      ttl  = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name = "jenkins-agent"
      type = "A"
      ttl  = 1
      records = [
        module.jenkins-agent.private_ip
      ]
      allow_overwrite = true
    },
  ]
}
