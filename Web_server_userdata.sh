#!/bin/bash
yum update -y
yum install -y httpd php php-mysqlnd mysql curl unzip
systemctl start httpd
systemctl enable httpd
cd /var/www/html
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
cat <<EOF > upload.php
<?php
$bucket = 'your-s3-bucket-name';
$region = 'your-region';
$name = $_POST['username'];
$file = $_FILES['fileToUpload']['name'];
$tmp = $_FILES['fileToUpload']['tmp_name'];
require 'vendor/autoload.php';
use Aws\S3\S3Client;
$s3 = new S3Client([
 'region' => '$region',
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
# Create DB Table (Optional)
mysql -h MYSQL_PRIVATE_IP -uwebadmin -pYourPassword123 -e "USE userdb; CREATE TABLE
users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), image VARCHAR(255));"
