#!/bin/bash

# Variables
# BACKEND_REPO_URL='https://github.com/Roni-Boiz/crispy-kitchen-backend.git'
BUCKET_NAME="${bucket_name}"
BACKEND_DIR="app-tier"
BACKEND_SVC_PORT="${server_port}"

# Set Variables for Ubuntu
HOME_DIR=$(eval echo ~)
PACKAGE="curl git mysql-client unzip"

# Set your desired Node.js version
NODE_VERSION="18.x"

echo "Running Setup on Ubuntu"

# Installing Dependencies
echo "########################################"
echo "Installing Packages"
echo "########################################"
sudo apt update
sudo apt install $PACKAGE -y > /dev/null
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
sudo rm -rf aws
echo

# Create Data Tables
echo "########################################"
echo "Create Data Tables"
echo "########################################"
cd $HOME_DIR
echo "${db_file}" | base64 --decode > /tmp/decoded_script.sql
sudo mysql -h "${db_host}" -u "${db_user}" -p"${db_password}" < /tmp/decoded_script.sql
echo

# Install Node.js
echo "########################################"
echo "Installing Node.js"
echo "########################################"
sudo curl -sL https://deb.nodesource.com/setup_$NODE_VERSION -o /tmp/nodesource_setup.sh
sudo bash /tmp/nodesource_setup.sh
sudo apt install -y nodejs
echo

# Clone Backend Repository
echo "########################################"
echo "Cloning Backend Repository"
echo "########################################"
cd $HOME_DIR
# sudo git clone $BACKEND_REPO_URL $BACKEND_DIR
aws s3 cp s3://$BUCKET_NAME/$BACKEND_DIR/ $BACKEND_DIR --recursive
echo

# Install Backend Dependencies
echo "########################################"
echo "Installing Backend Dependencies"
echo "########################################"
cd $BACKEND_DIR
sudo npm install -g pm2
sudo npm install
echo

# Set environment variables for the database
echo "########################################"
echo "Export Environment Variables"
echo "########################################"
export DB_HOST="${db_host}"
export DB_PORT="${db_port}"
export DB_USER="${db_user}"
export DB_PASSWORD="${db_password}"
export DB_NAME="${db_name}"
export PORT="${server_port}"

# Start Backend Server
echo "########################################"
echo "Starting Backend Server"
echo "########################################"
pm2 start index.js --name "backend" -- start
pm2 list
pm2 logs
pm2 startup
pm2 save --force
echo

# Test App Server
echo "########################################"
echo "Testing App Server"
echo "########################################"
curl http://localhost:4000/health
echo "Setup Complete"
echo

# Create Private Key
echo "########################################"
echo "Create Private Key"
echo "########################################"
aws ssm get-parameter --name "/myapp/secrets/private/ec2-instance-key" --with-decryption --query "Parameter.Value" --output text > $HOME_DIR/ec2-instance-key.pem
sudo chmod 600 $HOME_DIR/ec2-instance-key.pem
echo

# Clean Up
echo "########################################"
echo "Removing Temporary Files"
echo "########################################"
sudo rm -rf /tmp
echo "Cleanup Done"
echo
