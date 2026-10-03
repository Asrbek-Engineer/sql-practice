-- Retrieve customers with a score not equal to 0

SELECT *
FROM customers
WHERE score != 0
 

-- Retrieve customer's name, country, from Germany

SELECT
first_name, country
FROM customers
WHERE country = 'Germany'