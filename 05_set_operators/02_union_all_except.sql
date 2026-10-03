/*
  Topic: UNION ALL and EXCEPT
  Database: UnionPractice (see 00_setup.sql)
*/

USE UnionPractice;

-- Task 1: Return all first names from customers and employees,
-- keeping duplicates.
SELECT
	C.first_name
FROM customers C
UNION ALL
SELECT
	E.first_name
FROM employees E;

-- Task 2: Return all customer_ids from current and archived orders,
-- keeping duplicates, sorted by customer_id.
SELECT
	O.customer_id
FROM orders O
UNION ALL
SELECT
	OA.customer_id
FROM orders_archive OA
ORDER BY customer_id;

-- Task 2b: Same query with UNION to compare results.
-- UNION removes duplicates; UNION ALL keeps them and is faster
-- because it skips the duplicate check.
SELECT
	O.customer_id
FROM orders O
UNION
SELECT
	OA.customer_id
FROM orders_archive OA
ORDER BY customer_id;

-- Task 3: Return names of customers who are not employees.
SELECT
	C.first_name
FROM customers C
EXCEPT
SELECT
	E.first_name
FROM employees E;

-- Task 4: Return customers who have current orders
-- but no archived orders.
SELECT
	O.customer_id
FROM orders O
EXCEPT
SELECT
	OA.customer_id
FROM orders_archive OA
ORDER BY customer_id;

-- Task 5: Return names of employees who are not customers.
-- Note: EXCEPT is not symmetric. A EXCEPT B returns different
-- results than B EXCEPT A.
SELECT
	E.first_name
FROM employees E
EXCEPT
SELECT
	C.first_name
FROM customers C;
