-- Create the database if it doesn't already exist
CREATE DATABASE IF NOT EXISTS tododatabase;

-- Use the created database
USE tododatabase;

-- Create the table if it doesn't already exist
CREATE TABLE IF NOT EXISTS todo (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    target_date DATE,
    is_done BOOLEAN NOT NULL
);
