#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo chmod -R 777 /var/www/html/
echo "Hello, Wellcome to us: $(hostname -f)" > /var/www/html/index.html