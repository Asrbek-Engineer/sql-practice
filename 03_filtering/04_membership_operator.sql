
/**************************************

		MEMBERSHIP OPERATOR

**************************************/

-- IN operator
-- Retrieve all customers from either Germany or USA
SELECT * FROM customers
WHERE country IN ('Germany', 'USA') -- better

-- can solve with comparison and logical operators
SELECT * FROM customers
WHERE country = 'Germany' OR country = 'USA'


-- NOT IN operator
-- Retrieve all customers from not either Germany or USA
SELECT * FROM customers
WHERE country NOT IN ('Germany', 'USA')
