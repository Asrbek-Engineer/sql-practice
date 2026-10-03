-- LEFT ANTI JOIN
/* Get all cutsomers who havent place eny order */
SELECT * FROM customers c
LEFT JOIN orders o
ON c.id = o.customer_id
WHERE o.customer_id IS NULL

-- RIGHT ANTI JOIN 
SELECT * 
FROM customers c
RIGHT JOIN orders o
ON c.id = o.customer_id
WHERE c.id IS NULL

-- USING LEFT JOIN AS RIGHT ANTI JOIN
SELECT *
FROM orders O
LEFT JOIN customers C
ON O.customer_id = C.id
WHERE C.id IS NULL

SELECT * FROM customers C
FULL JOIN orders o
ON c.id = o.customer_id

-- FULL ANTI JOIN
SELECT *
FROM customers C
FULL JOIN orders O
ON C.id = O.customer_id
WHERE C.id IS NULL OR O.customer_id IS NULL

/* Get all customers along with their orders, but only customers who have placed an order 
Without INNER JOIN*/
SELECT * FROM customers c
LEFT JOIN orders o
ON c.id = o.customer_id
WHERE o.customer_id IS NOT NULL

-- CROSS JOIN
SELECT * 
FROM customers C
CROSS JOIN orders O