-- Find the total score for each country

SELECT country, score
FROM customers

SELECT
	country,
	SUM(score) AS total_score
FROM customers
GROUP BY country

-- Find the total score and total number of customers for each country

SELECT
	country,
	SUM(score) AS total_score,
	COUNT(id) AS total_number
FROM customers
GROUP BY country