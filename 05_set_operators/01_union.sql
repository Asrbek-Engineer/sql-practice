USE UnionPractice;

-- Task 1: All unique first names from customers and employees
SELECT 
	c.first_name
FROM customers c
UNION
SELECT 
	e.first_name
FROM employees e

-- Task 3: All names with their source table, sorted by name
-- Note: UNION removes duplicates by the whole row,
-- so 'Ali' appears twice (Customer and Employee).
SELECT 
	o.customer_id
FROM orders o
UNION
SELECT 
	oa.customer_id
FROM orders_archive oa

-- 3
SELECT 
	c.first_name, 'Customer' AS source
FROM customers c
UNION
SELECT
	e.first_name, 'Employee' AS source
FROM employees e
ORDER BY first_name
