/* Delete all customers with an ID greater than 5*/
DELETE FROM customers
WHERE ID > 5

SELECT * FROM customers

/* Delete all the data from table persons*/
DELETE FROM persons

-- TRUNCATE - Clears the whole table at once without checking or logging, VERY FAST than DELETE command
TRUNCATE TABLE persons

