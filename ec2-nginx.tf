module "nginx_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.6"

  name                       = "nginx-instance"
  ami                        = "ami-02d26659fd82cf299"
  instance_type              = "t2.micro"
  key_name                   = aws_key_pair.generated.key_name
  vpc_security_group_ids     = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  root_block_device = [
    {
      volume_size = 15
      volume_type = "gp3"
    }
  ]
}
