-- SET password for postgres user
ALTER USER postgres WITH PASSWORD 'secret';

CREATE ROLE barman WITH SUPERUSER LOGIN REPLICATION PASSWORD 'barmanpass';

-- CREATE DATABASE COMPANY
CREATE DATABASE company WITH OWNER postgres TEMPLATE template0 ENCODING 'UTF8';
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(100),
    age INT,
    email VARCHAR(100)
);

INSERT INTO employees (name, department, age, email) VALUES
('Alice', 'HR', 30, 'alice@example.com'),
('Bob', 'Engineering', 28, 'bob@example.com'),
('Charlie', 'Marketing', 32, 'charlie@example.com'),
('Diana', 'Sales', 27, 'diana@example.com'),
('Eve', 'IT', 35, 'eve@example.com');

-- RELOAD DATABASE CONFIGURATION
