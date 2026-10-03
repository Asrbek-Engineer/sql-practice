-- Retrieve only 3 Customers

SELECT TOP 3 *
FROM customers


-- Retrieve the Top 3 Customers with the Highest Scores
SELECT TOP 3 *
FROM customers
ORDER BY score DESC


-- Get the Two Most Recent Orders
SELECT TOP 2 *
FROM orders
ORDER BY order_date DESC