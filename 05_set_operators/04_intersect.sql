/*
  Topic: INTERSECT
  Database: UnionPractice (see 00_setup.sql)
*/

USE UnionPractice;

-- Task 1: Return names of people who are both customers and employees.
SELECT
	first_name
FROM customers
INTERSECT
SELECT
	first_name
FROM employees;

-- Task 2: Return customers who have both current and archived orders.
SELECT
	customer_id
FROM orders
INTERSECT
SELECT
	customer_id
FROM orders_archive;

-- Task 3: Return customers from Uzbekistan who have archived orders.
SELECT
	customer_id
FROM customers
WHERE country = 'UZ'
INTERSECT
SELECT
	customer_id
FROM orders_archive;

-- Task 4: Operator precedence.
-- INTERSECT is evaluated before UNION and EXCEPT.
-- Step 1: orders_archive INTERSECT DE customers = {3}
-- Step 2: orders UNION {3} = {1, 2, 3}
-- Parentheses make the evaluation order explicit and readable.
SELECT
	customer_id
FROM orders
UNION
(
	SELECT
		customer_id
	FROM orders_archive
	INTERSECT
	SELECT
		customer_id
	FROM customers
	WHERE country = 'DE'
);

-- Task 5: Task 2 rewritten with INNER JOIN + DISTINCT.
-- INTERSECT returns distinct rows by default;
-- INNER JOIN needs DISTINCT to avoid duplicates in one-to-many joins.
SELECT DISTINCT
	O.customer_id
FROM orders O
INNER JOIN orders_archive OA
	ON O.customer_id = OA.customer_id;