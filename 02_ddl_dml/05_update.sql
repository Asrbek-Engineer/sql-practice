/* Change the score of customer 6 to 0*/
SELECT * FROM customers

UPDATE customers
SET	score = 0
WHERE id = 6

SELECT * FROM customers

/* Change the score fo customer with ID 5 to 0 and update the country to 'UK'*/
UPDATE customers
SET score = 0,
	country = 'UK'
WHERE id = 5

SELECT * FROM customers

/* Update all customers with a 0 score by setting their score to NULL*/
UPDATE customers
SET score = NULL
WHERE score = 0

SELECT * FROM customers