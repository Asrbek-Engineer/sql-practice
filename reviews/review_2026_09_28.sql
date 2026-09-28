-- Review: set operators and string functions (written from memory, 28.09.2026)
USE UnionPractice;

-- Task 1: Find rows that exist in customers_load2 but not in customers_load1
-- (new or changed customers).
SELECT customer_id, first_name, country FROM customers_load2
EXCEPT
SELECT customer_id, first_name, country FROM customers_load1;

-- Task 2: Find rows that exist in customers_load1 but not in customers_load2
-- (deleted customers or old versions of changed rows).
SELECT customer_id, first_name, country FROM customers_load1
EXCEPT
SELECT customer_id, first_name, country FROM customers_load2;

-- Task 3: Combine both differences into one result
-- and add a change_type column ('in_load2_only' / 'in_load1_only').
(
	SELECT customer_id, first_name, country, 'in_load2_only' AS change_type
	FROM customers_load2
	EXCEPT
	SELECT customer_id, first_name, country, 'in_load2_only'
	FROM customers_load1
)
UNION ALL
(
	SELECT customer_id, first_name, country, 'in_load1_only' AS change_type
	FROM customers_load1
	EXCEPT
	SELECT customer_id, first_name, country, 'in_load1_only'
	FROM customers_load2
);

-- Task 4: Find contacts whose full_name has extra leading or trailing spaces.
-- Note: LEN ignores trailing spaces; DATALENGTH counts them.
SELECT
	full_name,
	TRIM(full_name) AS clean_full_name
FROM raw_contacts
WHERE DATALENGTH(full_name) <> DATALENGTH(TRIM(full_name));

-- Task 5: Clean phone numbers (remove '-' and spaces) and add '+' at the start.
SELECT
	phone,
	CONCAT('+', REPLACE(REPLACE(REPLACE(phone, ' ', ''), '-', ''), '+', '')) AS clean_phone
FROM raw_contacts;

-- Task 6: Combine names from customers and employees into one list,
-- show names in uppercase and add a source column ('customer' / 'employee').
SELECT
	UPPER(first_name) AS upper_first_name, 'customer' AS source
FROM customers
UNION
SELECT
	UPPER(first_name), 'employee'
FROM employees;

-- Task 7: Find customers who have orders in orders_archive but not in orders.
SELECT customer_id FROM orders_archive
EXCEPT
SELECT customer_id FROM orders;