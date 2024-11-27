output "cloudfront_distribution_domain_name" {
  value = module.cloudfront.cloudfront_domain_name
}

output "rds_cluster_primary_endpoint" {
  value = module.rds.primary_endpoint
}

output "rds_cluster_reader_endpoint" {
  value = module.rds.reader_endpoint
}