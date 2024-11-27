-- Setup the database and table
CREATE DATABASE IF NOT EXISTS webappdb;
USE webappdb;

-- Create transactions table
CREATE TABLE IF NOT EXISTS transactions (
    id INT NOT NULL AUTO_INCREMENT,
    amount DECIMAL(10,2),
    description VARCHAR(100),
    PRIMARY KEY(id)
);

-- Insert sample data
INSERT INTO transactions (amount, description) 
VALUES (400.00, 'groceries');