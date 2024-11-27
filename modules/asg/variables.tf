variable "project_name" {}
variable "ami" {
  default = "ami-0522ab6e1ddcc7055"
}
variable "cpu" {
  default = "t3.small"
}
variable "key_name" {}
variable "max_size" {
  default = 4
}
variable "min_size" {
  default = 1
}
variable "desired_cap" {
  default = 2
}
variable "asg_health_check_type" {
  default = "ELB"
}
variable "pub_sub_1a_id" {}
variable "pub_sub_2b_id" {}
variable "pri_sub_3a_id" {}
variable "pri_sub_4b_id" {}

variable "web_tier_sg_id" {}
variable "app_tier_sg_id" {}
variable "web_tier_tg_arn" {}
variable "app_tier_tg_arn" {}

variable "db_host" {}
variable "db_port" {
  default = 3306
}
variable "db_user" {}
variable "db_password" {}
variable "db_name" {}
variable "db_file" {
  default = "./modules/rds/setup.sql"
}
variable "domain" {}
variable "server_port" {
  default = 4000
}
variable "bucket_name" {}
variable "internal_alb_dns" {}
variable "rds_aurora_cluster_instance" {}