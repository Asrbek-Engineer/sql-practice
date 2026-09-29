-- Date practice: YEAR, MONTH, DAY, DATEPART, DATENAME, DATETRUNC, EOMONTH
-- Database: SalesDB
USE SalesDB;

/* ============ Part 1: Extraction (~15 min) ============ */

-- Task 1: Show orderid, orderdate and the year, month and day of orderdate.
select
	orderid,
	orderdate,
	year(orderdate) as year,
	month(orderdate) as month,
	day(orderdate) as day
from Sales.Orders;

-- Task 2: Show orderid, orderdate and a quarter label like 'Q1', 'Q2'.
select
	orderid,
	orderdate,
	concat('Q', datepart(quarter, orderdate)) as quarter_label
from Sales.Orders;

-- Task 3: Show orderid, orderdate, the month name and the weekday name of orderdate.
select
	orderid,
	orderdate,
	datename(month, orderdate) as name_of_month,
	datename(weekday, orderdate) as name_of_weekday
from Sales.Orders;

-- Task 4: Show each employee's firstname, birth year and birth month name (sales.Employees).
select 
	firstname,
	year(birthdate) as birth_year,
	datename(month, birthdate) as birth_month
from sales.Employees;

/* ============ Part 2: Filtering (~15 min) ============ */

-- Task 5: Show all orders placed in February.
select
	orderid,
	orderdate,
	month(orderdate) as month,
	datename(month, orderdate) as name_of_month
from Sales.Orders
where month(orderdate) = 2;


-- Task 6: Show orders that were shipped on a weekend (Saturday or Sunday).
-- Note: DATENAME result depends on the server language setting
select 
	orderid,
	shipdate,
	datename(weekday, shipdate) as weekday
from sales.Orders
where datename(weekday, shipdate) in ('Saturday', 'Sunday');

-- Task 7: Show orders where orderdate and shipdate fall in different months.
-- Think: is comparing only the month enough?
select
	orderid,
	orderdate,
	shipdate
from sales.orders
where month(orderdate) <> month(shipdate) OR year(orderdate) <> year(shipdate);

-- Task 8: Show employees born in the first quarter of the year (January to March).
select
	EmployeeID,
	datepart(quarter, birthdate) as quarter_of_birth_date,
	datename(month, birthdate) as birth_month
from sales.Employees
where datepart(quarter, birthdate) = 1;

/* ============ Part 3: Transformation (~15 min) ============ */

-- Task 9: Show creationtime truncated to the start of the month and to the start of the hour.
select
	orderid,
	datetrunc(month, creationtime) as month_trunc,
	datetrunc(hour, creationtime) as hour_trunc
from sales.Orders;

-- Task 10: Show orderdate, the first day of its month and the last day of its month side by side.
select
	orderid,
	orderdate,
	datetrunc(month, orderdate) as first_day,
	eomonth(orderdate) as last_day
from sales.Orders;

-- Task 11: Build a label like 'Jan-2025' from orderdate (3-letter month name + '-' + year).
select
	orderid,
	concat(left(datename(month, orderdate), 3), '-', year(orderdate)) month_year
from sales.Orders;

/* ============ Part 4: Counting (~15 min) ============ */

-- Task 12: Show the number of orders for each month (use the month name).
select
	month(orderdate) as month,
	datename(month, orderdate) as month_name,
	count(*) as count
from sales.Orders
group by month(orderdate), datename(month, orderdate);

-- Task 13: Show the number of orders for each weekday name.
select
	datename(weekday, orderdate) as weekday,
	count(*) as count
from sales.Orders
group by datename(weekday, orderdate);

-- Task 14: Show the number of orders for each month, from the busiest month to the quietest.
select
	month(orderdate) as month,
	datename(month, orderdate) as month_name,
	count(*) as count
from sales.Orders
group by month(orderdate), datename(month, orderdate)
order by count(*) desc;

/* ============ Bonus ============ */

-- Bonus: Show orders that were placed on the last day of a month.
select
	orderid,
	orderdate
from sales.Orders
where orderdate = eomonth(orderdate);