# resource "aws_instance" "web" {
#   ami                         = "ami-0522ab6e1ddcc7055"
#   instance_type               = "t2.micro"
#   key_name                    = var.key_name
#   subnet_id                   = [var.pub_sub_1a_id, var.pub_sub_2b_id]
#   vpc_security_group_ids      = [var.web_security_group_id]
#   associate_public_ip_address = true
#   count                       = 2

#   tags = {
#     Name = "WebServer"
#   }

#   provisioner "file" {
#     source      = "./modules/key/my-key.pem"
#     destination = "/home/ec2-user/ec2-instance-key.pem"

#     connection {
#       type        = "ssh"
#       host        = self.public_ip
#       user        = "ubuntu"
#       private_key = file("./modules/key/my-key.pem")
#     }
#   }
# }

# resource "aws_instance" "app" {
#   ami                         = "ami-0522ab6e1ddcc7055"
#   instance_type               = "t2.micro"
#   key_name                    = var.key_name
#   subnet_id                   = [var.pri_sub_3a_id, var.pri_sub_4b_id]
#   vpc_security_group_ids      = [var.app_security_group_id]
#   associate_public_ip_address = true
#   count                       = 2

#   tags = {
#     Name = "AppServer"
#   }

#   provisioner "file" {
#     source      = "./modules/key/my-key.pem"
#     destination = "/home/ec2-user/ec2-instance-key.pem"

#     connection {
#       type        = "ssh"
#       host        = self.public_ip
#       user        = "ubuntu"
#       private_key = file("./modules/key/my-key.pem")
#     }
#   }
# }

# resource "aws_instance" "db" {
#   ami                    = "ami-0522ab6e1ddcc7055"
#   instance_type          = "t2.micro"
#   key_name               = var.key_name
#   subnet_id              = [var.pri_sub_5a_id, var.pri_sub_6b_id]
#   vpc_security_group_ids = [var.db_security_group_id]

#   tags = {
#     Name = "DBServer"
#   }
# }