#!/bin/bash

# Variables
# FRONTEND_REPO_URL='https://github.com/Roni-Boiz/crispy-kitchen-frontend.git'
BUCKET_NAME="${bucket_name}"
FRONTEND_DIR="web-tier"
INTERNAL_ALB_DNS="${internal_alb_dns}"

# Set Variables for Ubuntu
HOME_DIR=$(eval echo ~)
PACKAGE="curl git mysql-client nginx unzip"

# Set Site Variables
NGINX_CONF="/etc/nginx/nginx.conf"

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
sudo rm -rf awscliv2.zip
echo

# Install Node.js
echo "########################################"
echo "Installing Node.js"
echo "########################################"
curl -sL https://deb.nodesource.com/setup_$NODE_VERSION -o /tmp/nodesource_setup.sh
sudo bash /tmp/nodesource_setup.sh
sudo apt install -y nodejs
echo

# Start & Enable Nginx Service
echo "########################################"
echo "Start & Enable Nginx Service"
echo "########################################"
sudo ufw allow 'Nginx Full'
sudo systemctl start nginx
sudo systemctl enable nginx
echo

# Clone Frontend Repository
echo "########################################"
echo "Cloning Frontend Repository"
echo "########################################"
cd $HOME_DIR
# sudo git clone $FRONTEND_REPO_URL $FRONTEND_DIR
aws s3 cp s3://$BUCKET_NAME/$FRONTEND_DIR/ $FRONTEND_DIR --recursive
echo

# Install Frontend Dependencies
echo "########################################"
echo "Installing Frontend Dependencies"
echo "########################################"
cd $FRONTEND_DIR
npm install
npm run build
echo

# Create Apache Configuration
echo "########################################"
echo "Creating Apache configuration"
echo "########################################"
if [ ! -f /etc/nginx/nginx.conf ]; then
    sudo touch /etc/nginx/nginx.conf
else
    sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf_bkp
fi
cat <<EOL | sudo tee $NGINX_CONF
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user www-data;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 4096;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.

    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;

        #health check
        location /health {
            default_type text/html;
            return 200 "<!DOCTYPE html><p>Web Tier Health Check</p>\n";
        }

        #react app and front end files
        location / {
            root $HOME_DIR/web-tier/build;
            index index.html index.htm;
            try_files \$uri /index.html;
        }

        #proxy for internal lb
        location /api/ {
            proxy_pass http://$INTERNAL_ALB_DNS:80/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }

    }
}
EOL

# Enable the New Site Configuration
echo "########################################"
echo "Enabling the new site configuration"
echo "########################################"
# sudo nginx -t && sudo systemctl reload nginx
sudo nginx -t && sudo systemctl restart nginx
echo

# Test App Server
echo "########################################"
echo "Testing App Server"
echo "########################################"
curl http://localhost/health
sudo chown -R www-data:www-data $HOME_DIR
sudo chmod -R 755 $HOME_DIR
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
