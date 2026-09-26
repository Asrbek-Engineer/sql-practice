/*
  Topic: Delta detection with EXCEPT (comparing two data loads)
  Use case: find new, changed and removed rows between daily loads.
*/

USE UnionPractice;

CREATE TABLE customers_load1 (customer_id INT, first_name VARCHAR(50), country VARCHAR(10));
CREATE TABLE customers_load2 (customer_id INT, first_name VARCHAR(50), country VARCHAR(10));

-- Kechagi yuklama
INSERT INTO customers_load1 VALUES (1,'Ali','UZ'), (2,'Vali','KZ'), (3,'Anna','DE');
-- Bugungi yuklama: Vali boshqa mamlakatga ko'chgan, Sara yangi
INSERT INTO customers_load2 VALUES (1,'Ali','UZ'), (2,'Vali','UZ'), (3,'Anna','DE'), (4,'Sara','UZ');

-- Task 1: Return new or changed rows in today's load.
SELECT customer_id, first_name, country FROM customers_load2
EXCEPT
SELECT customer_id, first_name, country FROM customers_load1;

-- Task 2: Return rows from yesterday's load that were changed or removed today.
SELECT customer_id, first_name, country FROM customers_load1
EXCEPT
SELECT customer_id, first_name, country FROM customers_load2;

-- Task 3: Return only newly added customers (changed ones excluded).
SELECT customer_id FROM customers_load2
EXCEPT
SELECT customer_id FROM customers_load1;

-- Task 4: Check whether both loads are identical (empty result = identical).
-- The change_type column shows which side each difference comes from.
(
	SELECT customer_id, first_name, country, 'old/removed' AS change_type
	FROM customers_load1
	EXCEPT
	SELECT customer_id, first_name, country, 'old/removed'
	FROM customers_load2
)
UNION ALL
(
	SELECT customer_id, first_name, country, 'new/changed'
	FROM customers_load2
	EXCEPT
	SELECT customer_id, first_name, country, 'new/changed'
	FROM customers_load1
);