-- CASE WHEN practice (~50 min)
-- Database: SalesDB
-- Before you submit, check 4 things:
--   1) Are all the columns the task asks for in the result?
--   2) Is any column used with / or AVG an INT? If so, cast it to DECIMAL first.
--   3) Are you grouping or sorting by a real date, not by text?
--   4) Does each alias describe its value?
USE SalesDB;

/* ============ Part 1: Categorizing (~10 min) ============ */

-- Task 1: Show orderid, sales and a sales_category column:
-- 'High' if sales > 50, 'Medium' if 21-50, 'Low' if 20 or less.
select
	orderid,
	sales,
	case
		when sales > 50 then 'High'
		when sales > 20 then 'Medium'
		else 'Low'
	end as sales_category
from sales.orders;

-- Task 2: Show total sales and number of orders for each sales_category from Task 1,
-- sorted from highest total sales to lowest.
select
	sum(sales) as total_sales,
	count(*) as nr_of_orders,
	case
		when sales > 50 then 'High'
		when sales > 20 then 'Medium'
		else 'Low'
	end as sales_category
from sales.orders
group by (case
			when sales > 50 then 'High'
			when sales > 20 then 'Medium'
			else 'Low'
		  end)
order by total_sales desc;

/* ============ Part 2: Mapping values (~10 min) ============ */

-- Task 3: Show each employee's firstname and gender as a full word:
-- 'M' -> 'Male', 'F' -> 'Female', anything else -> 'Not Available'.
select
	firstname,
	case gender
		when 'F' then 'Female'
		when 'M' then 'Male'
		else 'Not Available'
	end as full_gender
from sales.employees;

-- Task 4: Show each customer's firstname, country and a country_code column:
-- 'Germany' -> 'DE', 'USA' -> 'US', anything else -> 'n/a'.
-- Write it with the short form: CASE country WHEN ... THEN ...
select
	firstname,
	country,
	case country
		when 'Germany' then 'DE'
		when 'USA' then 'US'
		else 'n/a'
	end as country_code
from sales.customers;

-- Task 5 (answer as a comment): Can you use the short form (CASE column WHEN ...)
-- for Task 1? Why or why not?
-- No we cannot use short form case because of comparison operators

/* ============ Part 3: CASE and NULLs (~8 min) ============ */

-- Task 6: Show customerid, score, and score_clean (NULL -> 0), using CASE only (no COALESCE or ISNULL).
-- Then, in a second query, show AVG(score) and the average of score_clean side by side.
-- 1st
select
	customerid,
	score,
	case
		when score is null then 0
		else score
	end as score_clean
from sales.customers;

-- 2nd
select
	avg(cast(score as decimal(10,2))) as avg_score,
	avg(case
		when cast(score as decimal(10,2)) is null then 0
		else cast(score as decimal(10,2))
	end) as avg_score_clean
from sales.customers;

/* ============ Part 4: Conditional aggregation (~12 min) ============ */

-- Task 7: For each customerid, show the total number of orders
-- and the number of orders with sales greater than 30.
select
	customerid,
	count(*) as total_nr_of_orders,
	sum(case
			when sales > 30 then 1
			else 0
		 end) as total_greater_nr_of_orders
from sales.orders
group by customerid
order by customerid;

-- Task 8: Show one row with two columns:
-- the number of 'Delivered' orders and the number of 'Shipped' orders (orderstatus).
select
	sum(case orderstatus when 'Delivered' then 1 else 0 end) as delivered_orders,
	sum(case orderstatus when 'Shipped' then 1 else 0 end) as shipped_orders
from sales.orders;

-- Task 9: Show one row with total sales from German customers and total sales from US customers
-- as two separate columns (join sales.Orders with sales.Customers).
select
	sum(case c.country when 'Germany' then o.sales else 0 end) as german_total_sales,
	sum(case c.country when 'USA' then o.sales else 0 end) as us_total_sales
from sales.orders as o
inner join sales.customers as c
	on o.customerid = c.customerid;

/* ============ Part 5: Traps and integration (~10 min) ============ */

-- Task 10: This query is wrong. Explain why as a comment, then fix it.
-- SELECT orderid, sales,
--     CASE
--         WHEN sales > 10 THEN 'Low'
--         WHEN sales > 50 THEN 'High'
--     END AS label
-- FROM sales.Orders;
-- Becase when first condition works then case operator skips next ones, order of conditions are essential
-- correct form:
SELECT orderid, sales,
    CASE
		WHEN sales > 50 THEN 'High'
        WHEN sales > 10 THEN 'Low'
		else 'unknown or so low' -- else it return null
    END AS label
 FROM sales.Orders;

-- Task 11 (answer as a comment): What does CASE return when no WHEN matches and there is no ELSE?
-- id in case statement there is no matches and no else operator then it returns null

-- Task 12: Show orderid, orderdate, shipdate and a shipping_speed column:
-- 'Not shipped' if shipdate is NULL, 'Fast' if 7 days or less,
-- 'Normal' if 8-14 days, 'Slow' if more than 14 days.
select
	orderid,
	orderdate,
	shipdate,
	case 
		when datediff(day, orderdate, shipdate) is null then 'Not shipped'
		when datediff(day, orderdate, shipdate) <= 7 then 'Fast'
		when datediff(day, orderdate, shipdate) <= 14 then 'Normal'
		else 'Slow'
	end shipping_speed 
from sales.orders;

-- Task 13: Show each employee's firstname, exact age in full years and an age_group column:
-- 'Under 30', '30-39', '40 and over'.
-- (Use the exact-age method from the date bonus, not DATEDIFF(year, ...).)
-- long form
select
	firstname,
	datediff(year, birthdate, getdate()) -
	case
		when datepart(month, birthdate) > datepart(month, getdate()) or
			datepart(month, birthdate) = datepart(month, getdate()) and 
			datepart(day, birthdate) > datepart(day, getdate()) then 1
		else 0
	end as exact_age,
	case
		when datediff(year, birthdate, getdate()) -
			case
				when datepart(month, birthdate) > datepart(month, getdate()) or
				datepart(month, birthdate) = datepart(month, getdate()) and 
				datepart(day, birthdate) > datepart(day, getdate()) then 1
				else 0
			end < 30 then 'Under 30'
		when datediff(year, birthdate, getdate()) -
			case
				when datepart(month, birthdate) > datepart(month, getdate()) or
				datepart(month, birthdate) = datepart(month, getdate()) and 
				datepart(day, birthdate) > datepart(day, getdate()) then 1
				else 0
			end >= 30 and datediff(year, birthdate, getdate()) -
			case
				when datepart(month, birthdate) > datepart(month, getdate()) or
				datepart(month, birthdate) = datepart(month, getdate()) and 
				datepart(day, birthdate) > datepart(day, getdate()) then 1
				else 0
			end < 40 then '30-39'
			else '40 and over'
		end as age_group
from sales.employees;

-- short form
select
	firstname,
	exact_age,
	case
		when exact_age < 30 then 'Under 30'
		when exact_age >= 30 and exact_age <= 39 then '30-39'
		else '40 and over'
	end age_group
from (
	select
		firstname,
		datediff(year, birthdate, getdate()) -
		case
			when datepart(month, birthdate) > datepart(month, getdate()) or
			datepart(month, birthdate) = datepart(month, getdate()) and 
			datepart(day, birthdate) > datepart(day, getdate()) then 1
			else 0
		end as exact_age
	from sales.employees) as data;

/* ============ Bonus ============ */

-- Bonus: Sort customers so that USA comes first, then Germany, then all other countries.
-- Inside each country, sort by score from highest to lowest (missing score last).
select
	country,
	score
from sales.customers
order by 
		case 
			when country = 'USA' then 1
			when country = 'Germany' then 2
			else 3
		end,
		case 
			when score is null then 1 
			else 0 end,
	score desc;