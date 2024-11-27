region                  = "ap-south-1"                          # AWS Region, example: US East (N. Virginia)
availability_zone       = ["ap-south-1a", "ap-south-1b"]        # AWS Availability zone
project_name            = "aws-3-tier"                          # Your project name
vpc_cidr                = "10.0.0.0/16"                         # CIDR block for the VPC
pub_sub_1a_cidr         = "10.0.1.0/24"                         # CIDR block for public subnet in availability zone 1a
pub_sub_2b_cidr         = "10.0.2.0/24"                         # CIDR block for public subnet in availability zone 2b
pri_sub_3a_cidr         = "10.0.3.0/24"                         # CIDR block for private subnet in availability zone 3a
pri_sub_4b_cidr         = "10.0.4.0/24"                         # CIDR block for private subnet in availability zone 4b
pri_sub_5a_cidr         = "10.0.5.0/24"                         # CIDR block for private subnet in availability zone 5a
pri_sub_6b_cidr         = "10.0.6.0/24"                         # CIDR block for private subnet in availability zone 6b
db_username             = "admin"                               # Database username
db_password             = "admin1234"                           # Database password
certificate_domain_name = "example.com"                         # Domain name for SSL certificate
additional_domain_name  = "www.example.com"                     # Additional domain name for the certificate
bucket_name             = "aws-3-tier-project-application-code" # Unique bucket name to store application code