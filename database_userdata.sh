#!/bin/bash
yum update -y
amazon-linux-extras enable mysql8.0
yum install -y mysql-server
systemctl start mysqld
systemctl enable mysqld
mysql <<EOF
CREATE DATABASE userdb;
CREATE USER 'webadmin'@'%' IDENTIFIED BY 'YourPassword123';
GRANT ALL PRIVILEGES ON userdb.* TO 'webadmin'@'%';
FLUSH PRIVILEGES;
EOF
