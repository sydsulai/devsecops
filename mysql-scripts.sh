## Install MySQL - Ignore it because we using AWS RDS.
sudo apt install mysql-server -y
sudo mysql

## Modify MYSQL Password
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password'; #Auth by Password
FLUSH PRIVILEGES;
EXIT;

## Login as user
sudo mysql -u root -p

## Create Database if not exist
CREATE DATABASE IF NOT EXISTS crud_app;
USE crud_app;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'viewer') NOT NULL DEFAULT 'viewer',
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);