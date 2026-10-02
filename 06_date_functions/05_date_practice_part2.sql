-- Date practice part 2: FORMAT, CONVERT, CAST, DATEADD, DATEDIFF, ISDATE
-- Database: SalesDB
USE SalesDB;

/* ============ Part 1: FORMAT (~12 min) ============ */

-- Task 1: Show orderid, orderdate in 'dd.MM.yyyy' format and in 'yyyy/MM/dd' format.
select
	orderid,
	orderdate,
	format(orderdate, 'dd.MM.yyyy') as first_format,
	format(orderdate, 'yyyy/MM/dd') as second_format
from sales.orders;

-- Task 2: Show orderid and sales with thousand separators and 2 decimals,
-- and the same value as US currency (culture 'en-US').
select
	orderid,
	format(sales, 'N2', 'en-US') as formatted_sales,
	format(sales, 'C', 'en-US') as usd_sales
from sales.orders;

-- Task 3: Show creationtime as time only ('HH:mm') and the short weekday name ('ddd').
select
	orderid,
	format(creationtime, 'HH:mm') as creation_time,
	format(creationtime, 'ddd') as short_weekday
from sales.orders;

-- Task 4: Build a label like 'Order 1 - Wed, 01 Jan 2025' for every order.
select
	concat('Order ', orderid, ' - ', format(orderdate, 'ddd, dd MMM yyyy')) as order_full_date
from sales.orders;

/* ============ Part 2: CONVERT and CAST (~15 min) ============ */

-- Task 5: Show creationtime converted to DATE,
-- and converted to VARCHAR with style 23 (yyyy-mm-dd) and style 104 (dd.mm.yyyy).
select
	orderid,
	convert(date, creationtime) as converted_date,
	convert(varchar(10), creationtime, 23) as style_date_23,
	convert(varchar(10), creationtime, 104) as style_date_104
from sales.orders;

-- Task 6: Convert the string '2025-08-20' to DATE and the string '123' to INT.
select
	convert(date, '2025-08-20') as exact_date,
	convert(int, '123') as number;

-- Task 7: Show creationtime cast to DATE and cast to TIME.
select
	orderid,
	cast(creationtime as date) as creation_date,
	cast(creationtime as time) as creation_time
from sales.orders;

-- Task 8: Show 'Total: ' + sales as one text column (cast sales to VARCHAR).
select
	orderid,
	concat('Total: ', cast(sales as varchar(10))) as total_sales
from sales.orders;

-- Task 9: Cast '45.7' to DECIMAL(5,1), then cast the same value to INT.
-- What happens to .7? Write the answer as a comment.
select
	cast('45.7' as decimal(5,1)) as decimal_number,
	cast(cast('45.7' as decimal(5,1)) as int) as integer_number; 
	-- because int gets integer part from decimal number, 
	-- integer do not rounds but cuts numbers after point 

-- Task 10 (theory, answer as a comment): What can CONVERT do that CAST cannot?
-- Answer: Convert can give optional style to the date and number while cast cannot,
-- Cast is SQL std. and works any databases while Convert works only SQL Server

/* ============ Part 3: DATEADD (~10 min) ============ */

-- Task 11: Show orderdate, the date 10 days later, 3 months later and 1 year earlier.
select
	orderid,
	orderdate,
	dateadd(day, 10, orderdate) as plus_10_days,
	dateadd(month, 3, orderdate) as plus_3_months,
	dateadd(year, -1, orderdate) as minus_1_year
from sales.orders;

-- Task 12: Orders should ship within 7 days. Show orderid, orderdate,
-- expected_ship_date (orderdate + 7 days) and shipdate,
-- only for orders shipped later than expected.
select
	orderid,
	orderdate,
	dateadd(day, 7, orderdate) as expected_ship_date,
	shipdate
from sales.orders
where dateadd(day, 7, orderdate) < shipdate;

/* ============ Part 4: DATEDIFF (~15 min) ============ */

-- Task 13: Show orderid, orderdate, shipdate and the number of days between them.
select
	orderid,
	orderdate,
	shipdate,
	datediff(day, orderdate, shipdate) as day_difference
from sales.orders;

-- Task 14: Show the average shipping time in days for each month of orderdate.
-- (Use AVG together with GROUP BY, like COUNT in the use-case lessons.)
select
	datetrunc(month, orderdate) as order_month,
	avg(cast(datediff(day, orderdate, shipdate) as decimal(10, 2))) as average_shipping_day
from sales.orders
group by datetrunc(month, orderdate)
order by order_month;

-- Task 15: Show each employee's firstname, birthdate and age in years (sales.Employees).
select
	employeeid,
	firstname,
	birthdate,
	datediff(year, birthdate, getdate()) as age
from sales.employees;

-- Task 16: Show how many days have passed from each orderdate until today.
select
	orderid,
	orderdate,
	datediff(day, orderdate, getdate()) as days_passed
from sales.orders;

/* ============ Part 5: ISDATE (~8 min) ============ */

-- Task 17: Check which of these values are valid dates:
-- '2025-08-20', '2025-13-01', '20-08-2025', '2025', 'hello'
-- Show each value and the result of ISDATE.
-- Hint: build the list with SELECT ... UNION ALL SELECT ...
select isdate('2025-08-20') as is_date, '2025-08-20' as string
UNION ALL
select isdate('2025-13-01'), '2025-13-01'
UNION ALL
select isdate('20-08-2025'), '20-08-2025'
UNION ALL
select isdate('2025'), '2025'
UNION ALL
select isdate('hello'), 'hello';

-- Task 18: From the same list, keep only the valid values and cast them to DATE.
select
	cast(string as date) as exact_date
from (
	select isdate('2025-08-20') as is_date, '2025-08-20' as string
	UNION ALL
	select isdate('2025-13-01'), '2025-13-01'
	UNION ALL
	select isdate('20-08-2025'), '20-08-2025'
	UNION ALL
	select isdate('2025'), '2025'
	UNION ALL
	select isdate('hello'), 'hello'
) as dates
where dates.is_date = 1;


/* ============ Bonus ============ */

-- Bonus: DATEDIFF(year, ...) counts year boundaries, not full years.
-- Example: birthdate 2000-12-31, today 2001-01-01 -> DATEDIFF says 1, real age is 0.
-- Write a query that shows each employee's exact age in full years.
select
	employeeid,
	firstname,
	birthdate,
	(cast(format(getdate(), 'yyyyMMdd') as int) - cast(format(birthdate, 'yyyyMMdd') as int)) / 10000 as exact_age
from sales.employees;