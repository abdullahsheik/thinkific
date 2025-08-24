-- Create database if it doesn't exist
SELECT 'CREATE DATABASE autoincrement_dev'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'autoincrement_dev')\gexec

SELECT 'CREATE DATABASE autoincrement_test'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'autoincrement_test')\gexec

SELECT 'CREATE DATABASE autoincrement_prod'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'autoincrement_prod')\gexec
