
/**************************************

		LOGICAL OPERATORS

**************************************/


-- AND operator
-- Retrieve all customers who are from the USA and have a score greater than 500
SELECT * FROM customers
WHERE country = 'USA' AND score > 500


-- OR operator
-- Retrieve all customers who are from the USA and have a score greater than 500
SELECT * FROM customers
WHERE country = 'USA' OR score > 500


-- NOT operator
-- Retrieve all customers with a score not less than 500
SELECT * FROM customers
WHERE NOT score < 500
