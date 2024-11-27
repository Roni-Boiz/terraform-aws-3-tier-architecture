# 🚀 Terraform AWS 3-Tier Architecture

✨ This repository is created to learn and deploy a 3-tier application on aws cloud through Terraform. 

<img src="https://raw.githubusercontent.com/Roni-Boiz/terraform-aws-3-tier-architecture/refs/heads/main/3TierArch.svg">

### 🏠 Let's set up the variable for our Infrastructure

Create one file with the name `terraform.tfvars`

```sh
vim terraform.tfvars
```

#### 🔐 ACM certificate

To use ACM certificate, go to AWS management console --> AWS Certificate Manager (ACM) and make sure you have a valid certificate in Issued status, if not, feel free to create one and use the domain name on which you are planning to host your application (Not Mandatory).

#### 👨‍💻 Route 53 Hosted Zone

To user Route 53 hosted zone, go to AWS management console --> Route53 --> Hosted Zones and ensure you have a public hosted zone available, if not create one (Not Mandatory).

#### Create Private and Public Key

In order to initiate AWS EC2 instance you need to have a key pair (public and private key). So remove any key (`my-key.pem`, `my-key.pub`) in following directory `./modules/key/*` then reate your own keys using following command:

```bash
$ cd ./modules/key
$ ssh-keygen -t rsa -b 4096 -f ./my-key.pem
$ mv my-key.pem.pub my-key.pub
```

Add the below content into the `terraform.tfvars` file and add the values of each variable.

```javascript
region                  = ""
project_name            = ""
vpc_cidr                = ""
pub_sub_1a_cidr         = ""
pub_sub_2b_cidr         = ""
pri_sub_3a_cidr         = ""
pri_sub_4b_cidr         = ""
pri_sub_5a_cidr         = ""
pri_sub_6b_cidr         = ""
db_username             = ""
db_password             = ""
certificate_domain_name = ""
additional_domain_name  = ""
```

#### ⚙️ Verify the resources

After completing above steps make sure you have enable route53 resource `./modules/route53/main.tf`, cloudfront acm certificate and aliases `./modules/cloudfront/main.tf`. Finally, make changes to auto scaling group `./modules/asg/config.sh` accordingly to deploy your application on following aws 3 tier architecture.

### ✈️ Now we are ready to deploy our application on the cloud 

👉 Let install dependency to deploy the application 

```sh
terraform init 
```

Type the below command to see the plan of the execution 

```sh
terraform plan
```

✨ Finally, HIT the below command to deploy the application

```sh
terraform apply 
```

Type `yes`, and it will prompt you for approval.

## Output

In order to automate the task and start the CI/CD pipeline, you will need a dedicated EC2 instance configured as a self-hosted runner in GitHub Actions. Set it up by registering the instance as a new self-hosted runner in your repository's GitHub Actions settings.

To receive pipeline deployment notifications, configure your Slack channel's webhook URL. Add this webhook URL as a repository secret in GitHub Actions > Secrets and Variables > Repository secrets, and name it `SLACK_WEBHOOK_URL`.

Upon successful execution, the pipeline will deploy a fully functional application in a 3-Tier Architecture on AWS Cloud.

### Sample Application


### Pipeline


### Slack Channel Notifications