-- String and number functions: LEN, LEFT, RIGHT, SUBSTRING, ROUND, ABS
USE UnionPractice;

-- Setup (run once)
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
	txn_id         INT,
	account_code   VARCHAR(20),     -- format: COUNTRY-CITY-NUMBER, e.g. 'UZ-TAS-00123'
	customer_email VARCHAR(50),
	amount         DECIMAL(10,3)    -- negative = refund
);
INSERT INTO transactions VALUES
(1, 'UZ-TAS-00123', 'ali.valiyev@gmail.com', 1250.456),
(2, 'UZ-SAM-00045', 'olga@mail.ru',          -320.500),
(3, 'KZ-ALM-01200', 'anna.schmidt@web.de',     89.994),
(4, 'UZ-TAS-00007', 'vali@gmail.com',          -15.250),
(5, 'DE-BER-00310', 'sara.k@outlook.com',    4000.005);


-- Task 1: Show each customer_email and its length.
-- Then show only emails longer than 15 characters.


-- Task 2: Extract the country code (first 2 characters) from account_code.


-- Task 3: Extract the account number (last 5 characters) from account_code.


-- Task 4: Extract the city code (characters 4 to 6) from account_code.


-- Task 5: Round amount to 2 decimal places, and separately to a whole number.


-- Task 6: Show the absolute value of amount.
-- Then show only transactions where the absolute amount is greater than 100.


-- Task 7: Build a short label like 'UZ-00123' (country code + '-' + account number)
-- and show the absolute amount rounded to a whole number next to it.


-- Bonus: Extract the username (the part before '@') from customer_email.
-- Hint: CHARINDEX('@', customer_email) returns the position of '@'.