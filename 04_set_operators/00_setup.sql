CREATE DATABASE UnionPractice;
GO
USE UnionPractice;
GO

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name  VARCHAR(50),
    country     VARCHAR(10)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name  VARCHAR(50),
    department  VARCHAR(20)
);

CREATE TABLE orders (
    order_id    INT PRIMARY KEY,
    customer_id INT
);

CREATE TABLE orders_archive (
    order_id    INT PRIMARY KEY,
    customer_id INT
);

INSERT INTO customers VALUES (1, 'Ali', 'UZ'), (2, 'Vali', 'KZ'), (3, 'Anna', 'DE');
INSERT INTO employees VALUES (1, 'Ali', 'IT'), (2, 'Olga', 'HR');
INSERT INTO orders VALUES (101, 1), (102, 2);
INSERT INTO orders_archive VALUES (90, 1), (91, 1), (92, 3);

SELECT * FROM customers;
