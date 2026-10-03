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
select 
	customer_email,
	len(customer_email) as length
from transactions;

select 
	customer_email,
	len(customer_email) as length
from transactions
where len(customer_email) > 15;


-- Task 2: Extract the country code (first 2 characters) from account_code.
select
	left(account_code, 2) as country_code
from transactions;

-- Task 3: Extract the account number (last 5 characters) from account_code.
select
	right(account_code, 5) as account_number
from transactions;

-- Task 4: Extract the city code (characters 4 to 6) from account_code.
select 
	substring(account_code, 4, 3) as city_code
from transactions;

-- Task 5: Round amount to 2 decimal places, and separately to a whole number.
select 
	round(amount, 2) as rounded,
	round(amount, 0) as rounded_whole
from transactions;

-- Task 6: Show the absolute value of amount.
-- Then show only transactions where the absolute amount is greater than 100.
select
	abs(amount) as  absolute_amount
from transactions;

select
	txn_id,
	abs(amount) as absolute_amount
from transactions
where abs(amount) > 100;

-- Task 7: Build a short label like 'UZ-00123' (country code + '-' + account number)
-- and show the absolute amount rounded to a whole number next to it.
select
	concat(left(account_code, 2), '-', right(account_code, 5)) as specific_code,
	abs(round(amount, 0)) as abs_amount
from transactions;
-- 2nd way
select
	REPLACE(account_code, SUBSTRING(account_code, 3, 4), '') as specific_code,
	abs(round(amount, 0)) as abs_amount
from transactions;


-- Bonus: Extract the username (the part before '@') from customer_email.
-- Hint: CHARINDEX('@', customer_email) returns the position of '@'.
select 
	left(customer_email, CHARINDEX('@', customer_email) - 1) as user_name
from transactions;