output "primary_endpoint" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.aurora_cluster.reader_endpoint
}

output "db_host" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}

output "db_port" {
  value = aws_rds_cluster.aurora_cluster.port
}

output "db_username" {
  value = aws_rds_cluster.aurora_cluster.master_username
}

output "db_password" {
  value = aws_rds_cluster.aurora_cluster.master_password
}

output "db_name" {
  value = aws_rds_cluster.aurora_cluster.database_name
}

output "rds_aurora_cluster" {
  value = aws_rds_cluster.aurora_cluster
}
