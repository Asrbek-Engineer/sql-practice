/*
  Topic: UNION ALL and EXCEPT - practice set 2
  Database: UnionPractice (see 00_setup.sql)
*/

USE UnionPractice;


-- Task 1: Return customers who have no current orders.
SELECT
	customer_id
FROM customers
EXCEPT
SELECT
	customer_id
FROM orders;

-- Task 2: Return customers who have no orders at all
-- (neither current nor archived).
-- UNION ALL is used inside because EXCEPT removes duplicates anyway.
SELECT
	customer_id
FROM customers
EXCEPT
(
	SELECT
		customer_id
	FROM orders
	UNION ALL
	SELECT
		customer_id
	FROM orders_archive
);

-- Task 3: Return all orders with a status column
-- ('current' or 'archived'), sorted by customer_id and order_id.
SELECT
	order_id, customer_id, 'current' AS status
FROM orders
UNION ALL
SELECT
	order_id, customer_id, 'archived'
FROM orders_archive
ORDER BY customer_id, order_id;

-- Task 4: Return names of customers from Uzbekistan
-- who are not employees.
SELECT
	first_name
FROM customers
WHERE country = 'UZ'
EXCEPT
SELECT
	first_name
FROM employees;

-- Bonus: Task 1 rewritten with LEFT JOIN + IS NULL (same result).
-- Note: NOT IN returns no rows if the subquery contains a NULL,
-- so EXCEPT or LEFT JOIN + IS NULL are safer for anti-joins.
SELECT
	C.customer_id
FROM customers C
LEFT JOIN orders O
	ON C.customer_id = O.customer_id
WHERE O.order_id IS NULL;