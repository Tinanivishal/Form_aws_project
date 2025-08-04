#!/bin/bash
yum update -y
yum install -y httpd php php-mysqlnd mysql curl unzip

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Change to web root
cd /var/www/html

# Create index.php (form)
cat <<EOF > index.php
<!DOCTYPE html>
<html>
<body>
<h2>User Registration</h2>
<form action="upload.php" method="post" enctype="multipart/form-data">
 Name: <input type="text" name="username"><br><br>
 Select image to upload: <input type="file" name="fileToUpload"><br><br>
 <input type="submit" value="Upload">
</form>
</body>
</html>
EOF

# Create upload.php (logic)
cat <<'EOF' > upload.php
<?php
require 'vendor/autoload.php';

$bucket = 'your-s3-bucket-name';
$region = 'your-region';
$name = $_POST['username'];
$file = $_FILES['fileToUpload']['name'];
$tmp = $_FILES['fileToUpload']['tmp_name'];

use Aws\S3\S3Client;

$s3 = new S3Client([
    'region' => $region,
    'version' => 'latest'
]);

$s3->putObject([
    'Bucket' => $bucket,
    'Key' => $file,
    'SourceFile' => $tmp
]);

$conn = new mysqli('MYSQL_PRIVATE_IP', 'webadmin', 'YourPassword123', 'userdb');
$conn->query("INSERT INTO users (name, image) VALUES ('$name', '$file')");

echo "Upload successful.";
?>
EOF

# Install Composer (for AWS SDK)
cd /var/www/html
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
composer require aws/aws-sdk-php

# Optional: create MySQL table
mysql -h MYSQL_PRIVATE_IP -uwebadmin -pYourPassword123 <<EOF
CREATE DATABASE IF NOT EXISTS userdb;
USE userdb;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    image VARCHAR(255)
);
EOF
