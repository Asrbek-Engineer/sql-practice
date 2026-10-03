
/**************************************

		COMPARISON OPERATORS

**************************************/


-- Equal(=) operator
-- Retrieve all customers who are from Germany.
SELECT * FROM customers
WHERE country = 'Germany'


-- Not Equal(!=) operator
-- Retrieve all customers who are not from Germany.
SELECT * FROM customers
WHERE country != 'Germany' -- We can use <>


-- Greater than (>) operator
-- Retrieve all customers with a score greater than 500.
SELECT * FROM customers
WHERE score > 500


-- Greater than (>=) or Equal to operator
-- Retrieve all customers with a score of 500 or more.
SELECT * FROM customers
WHERE score >= 500


-- Less than (<) operator
-- Retrieve all customers with a score less than 500.
SELECT * FROM customers
WHERE score < 500


-- Less than (<) or Equal to operator
-- Retrieve all customers with a score 500 or less
SELECT * FROM customers
WHERE score <= 500
