
/**************************************

		SEARCH OPERATOR

**************************************/


-- LIKE value% operator
-- Find all customers whose first name starts with 'M'
SELECT * FROM customers
WHERE first_name LIKE 'M%'


-- LIKE %value operator
-- Find all customers whose first name ends with 'n'
SELECT * FROM customers
WHERE first_name LIKE '%n'


-- LIKE %value% operator
-- Find all customers whose first name contains 'r'
SELECT * FROM customers
WHERE first_name LIKE '%r%'


-- LIKE 3rd_value% operator
-- Find all customers whose first name has 'r' in the 3rd position
SELECT * FROM customers
WHERE first_name LIKE '__r%'


