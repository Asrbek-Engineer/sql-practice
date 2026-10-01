-- Quick practice: CAST and DATEDIFF
USE SalesDB;

-- Task 1: Show orderid and a text column like 'Ordered on: 2025-01-01'
-- (cast orderdate to VARCHAR).
select
	orderid,
	concat('Ordered on: ', cast(orderdate as varchar(10))) as ordered
from sales.orders;

-- Task 2: Show orderid, sales, quantity and the price per unit (sales / quantity).
-- Then fix it so the result keeps decimals. Hint: integer division.
select
	orderid,
	sales,
	quantity,
	cast(sales as decimal(10,2)) / quantity as price
from sales.orders
where quantity <> 0;

-- Task 3: Show all orders placed after '2025-02-15'
-- (cast the string to DATE in the WHERE clause).
select
	OrderID, 
	ProductID, 
	CustomerID, 
	SalesPersonID, 
	OrderDate, 
	ShipDate, 
	OrderStatus, 
	ShipAddress, 
	BillAddress, 
	Quantity, 
	Sales, 
	CreationTime
from sales.orders
where cast('2025-02-15' as date) < orderdate;

-- Task 4: Show orderid, orderdate, shipdate and shipping days.
-- Show only orders that took more than 5 days.
select
	orderid,
	orderdate,
	shipdate,
	datediff(day, orderdate, shipdate) as shipping_days
from sales.orders
where datediff(day, orderdate, shipdate) > 5;

-- Task 5: Show orderid, orderdate and how many months have passed until today.
select
	orderid,
	orderdate,
	datediff(month, orderdate, getdate()) as months_passed
from sales.orders;

-- Task 6: Show employees who are older than 40 (sales.Employees).
-- Comment: why can DATEDIFF(year, ...) be slightly wrong here?
select
	employeeid,
	firstname,
	lastname,
	birthdate
from sales.employees
where datediff(year, birthdate, getdate()) > 40; -- slightly because datediff finds only by year not considering months and days

-- approximate version (365 days per year, ignores leap years; exact version needs CASE)
select
	employeeid,
	firstname,
	lastname,
	birthdate,
	cast(cast(datediff(day, birthdate, getdate()) as decimal) / 365 as int) as age
from sales.employees
where cast(datediff(day, birthdate, getdate()) as decimal) / 365 > 40;