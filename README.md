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

#### 🛡 Create Private and Public Key

In order to initiate AWS EC2 instance you need to have a key pair (public and private key). So remove any key (`my-key.pem`, `my-key.pub`) in following directory `./modules/key/*` then recreate your own keys using following command:

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
bucket_name             = ""
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

### ♾️ Automate

In order to automate the task and start the CI/CD pipeline, you will need a dedicated EC2 instance configured as a self-hosted runner in GitHub Actions. Set it up by registering the instance as a new self-hosted runner in your repository's GitHub Actions settings then name the runner as `git-workflow` as shown below. Please make sure to attach a suitable role with necessory permission to this instance while laungching or through Instances --> Actions --> Security --> Modify IAM role.

![ec2-runner](https://github.com/user-attachments/assets/6a046f6e-0cab-4245-bdd0-cc76c8888d80)

To receive pipeline deployment notifications, configure your Slack channel's webhook URL. Add this webhook URL as a repository secret in GitHub Actions --> Secrets and Variables --> Repository secrets, and name it `SLACK_WEBHOOK_URL`.

![slack-web-hook](https://github.com/user-attachments/assets/3c28f8c7-29d9-4933-9548-b9975c89515c)

Upon successful execution, the pipeline will deploy a fully functional application in a 3-Tier Architecture on AWS Cloud.

![runner-1](https://github.com/user-attachments/assets/96b93af5-7e22-40ea-b58f-3de392b5df84)

![runner-2](https://github.com/user-attachments/assets/05afa19a-7a54-401d-86a1-d99810a74eac)

## Output

### Sample Application

![app-1](https://github.com/user-attachments/assets/3c6ee116-207c-4bbe-8784-e07812e52a2c)

![app-2](https://github.com/user-attachments/assets/96f5bc10-6331-411e-af30-faf89ca65168)

![app-3](https://github.com/user-attachments/assets/b973b63d-57a3-4f1b-8ce8-52c3a357d9fc)


### Pipeline

![pipeline](https://github.com/user-attachments/assets/015ee177-a3d0-4d6d-9960-4d1e82cf3e52)


### Slack Channel Notifications

![slack-1](https://github.com/user-attachments/assets/fedce9c4-2b79-486b-90d4-f0d49f06dfe1)
