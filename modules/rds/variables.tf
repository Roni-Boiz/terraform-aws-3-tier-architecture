variable "db_sg_id" {}
variable "pri_sub_5a_id" {}
variable "pri_sub_6b_id" {}
variable "db_username" {}
variable "db_password" {}
variable "db_sub_name" {
  default = "transaction-db-subnet-a-b"
}
variable "db_name" {
  default = "webappdb"
}