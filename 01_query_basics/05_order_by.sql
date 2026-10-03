-- Retrieve all customers and sort the results by the highest score first

SELECT *
FROM customers
ORDER BY score DESC

-- Retrieve all customers and sort the results by the country and by the highest score

SELECT *
FROM customers
ORDER BY country ASC, score DESC

--* Column order in ORDER BY is crucial, as sorting is sequential