resource "aws_key_pair" "my_key_pair" {
  key_name   = "ec2-instance-key"
  public_key = file("./modules/key/my-key.pub")
}

resource "aws_ssm_parameter" "private_key" {
  name  = "/myapp/secrets/private/ec2-instance-key"
  type  = "SecureString"
  value = file("./modules/key/my-key.pem")
}
