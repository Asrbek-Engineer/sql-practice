use UnionPractice;


-- Task 1: Show the first 3 letters of each customer's first_name in uppercase (customers).
select 
	upper(left(first_name, 3)) as first_name3
from customers;

-- Task 2: Show each full_name from raw_contacts after trimming, and its length.
select
	full_name, 
	len(full_name) as length, 
	trim(full_name) as clean_full_name, 
	len(trim(full_name)) as clean_length
from raw_contacts;

-- Task 3: Mask phone numbers in raw_contacts: remove '-' and spaces,
-- then show only the last 4 digits with '***' in front (e.g. '***4567').
select
	concat('***', right(replace(replace(phone, '-', ''), ' ', ''), 4)) as semihidden_phone
from raw_contacts;

-- Task 4: Extract the email domain (the part after '@') from transactions.customer_email.
-- Hint: SUBSTRING + CHARINDEX + LEN.
select
	customer_email,
	substring(customer_email, charindex('@', customer_email) + 1, len(customer_email)) as email_domain
from transactions;

-- 2nd way
select
	customer_email,
	right(customer_email, len(customer_email) - charindex('@', customer_email)) as email_domain
from transactions;

-- Task 5: Show only refunds (amount < 0) from transactions,
-- with the amount as a positive number rounded to 1 decimal place.
select
	txn_id,
	round(abs(amount), 1) as refund_amount
from transactions
where amount < 0;