resource "aws_db_subnet_group" "db-subnet" {
  name       = var.db_sub_name
  subnet_ids = [var.pri_sub_5a_id, var.pri_sub_6b_id] # Replace with your private subnet IDs
  tags = {
    Name = "aurora-db-subnet-group"
  }
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier     = "transaction-cluster"
  engine                 = "aurora-mysql"
  engine_version         = "8.0.mysql_aurora.3.04.0"
  master_username        = var.db_username
  master_password        = var.db_password
  database_name          = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
  storage_encrypted      = false
  vpc_security_group_ids = [var.db_sg_id]
  skip_final_snapshot    = true

  backup_retention_period = 1
  tags = {
    Name = "webappdb"
  }
}

resource "aws_rds_cluster_instance" "primary" {
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = "db.t3.medium"
  engine              = "aurora-mysql"
  availability_zone   = "ap-south-1a"
  publicly_accessible = false
}

resource "aws_rds_cluster_instance" "replica" {
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = "db.t3.medium"
  engine              = "aurora-mysql"
  availability_zone   = "ap-south-1b"
  publicly_accessible = false
}