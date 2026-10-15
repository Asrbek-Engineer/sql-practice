-- CTE practice + review (~55 min)
-- Database: SalesDB
-- Before each query, write the columns the task asks for as a comment.
-- Mark each task: -- ✓ (sure) or -- ? (not sure)
-- Before you submit, check 6 things:
--   1) Are all the columns the task asks for in the result?  (re-read the task, word by word)
--   2) Is any column used with / or AVG an INT? If so, cast it to DECIMAL first.
--   3) Are you grouping or sorting by a real date, not by text or month number?
--   4) Does each alias describe its value?
--   5) Did you look at 1-2 result rows and check them by eye?
--   6) Did you apply every feedback rule to the whole file?
USE SalesDB;

/* ============ Review: Default frame (+3 days, NO notes) ============ */

-- R1: Show orderid, orderdate, sales and two running totals side by side, both ordered by
-- DATETRUNC(month, orderdate): one WITHOUT a frame, one WITH ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.
-- Comment: why are the two values different for orders in the same month?
select
	orderid,
	orderdate,
	sales,
	sum(sales) over(order by datetrunc(month, orderdate)) as running_total_sales1,
	sum(sales) over(order by datetrunc(month, orderdate) rows between unbounded preceding and current row) as running_total_sales2
from sales.orders;
-- in first running total sales  standart frame is range all rows considered equal in every month 
-- so sums all sales for that month until end of month
-- in second running total sales adds sales row by row starting point is first row table

/* ============ Part 1: Standalone and multiple CTEs (~15 min) ============ */

-- Task 1: Rewrite Subquery Task 3 with a CTE:
-- every customer's customerid, firstname, number of orders and total sales (0 for customers with no orders).
with cte_customer_data as
(
	select
		customerid,
		count(*) as nr_of_orders,
		sum(sales) as total_sales
	from sales.orders
	group by customerid
)
select
	c.customerid,
	c.firstname,
	coalesce(ccd.nr_of_orders, 0) as nr_of_orders,
	coalesce(ccd.total_sales, 0) as total_sales
from sales.customers as c
left join cte_customer_data as ccd
	on ccd.customerid = c.customerid;

-- Task 2: Use two CTEs: the first finds the total sales of each product,
-- the second finds the average of those product totals.
-- Show product (name), its total sales and the average product total (DECIMAL, 2 decimals),
-- only for products whose total sales are above that average.
with cte_total_sales as
(
	select
		productid,
		sum(sales) as total_sales
	from sales.orders
	group by productid
)
, cte_avg_sales as
(
	select
		productid,
		cast(avg(cast(cts.total_sales as decimal(10, 2))) over() as decimal(10, 2)) as avg_sales
	from cte_total_sales as cts
)
select
	p.product,
	cts.total_sales,
	cas.avg_sales
from sales.products as p
inner join cte_total_sales as cts
	on cts.productid = p.productid
inner join cte_avg_sales as cas
	on cas.productid = p.productid
where cts.total_sales > cas.avg_sales;

-- Task 3 (trap from the lesson): Segment ALL customers by total sales:
-- 'High' if > 100, 'Medium' if > 80, 'Low' otherwise, and 'No orders' for customers without orders.
-- Show customerid, firstname, total_sales and the segment. No NULL in the segment column.
with cte_total_sales as
(
	select
		customerid,
		sum(sales) as total_sales
	from sales.orders
	group by customerid
)
select 
	c.customerid,
	c.firstname,
	coalesce(cts.total_sales, 0) as total_sales,
	case
		when cts.total_sales > 100 then 'High'
		when cts.total_sales > 80 then 'Medium'
		when cts.total_sales is null then 'No orders'
		else 'Low'
	end as segment
from sales.customers as c
left join cte_total_sales as cts
	on cts.customerid = c.customerid;

/* ============ Part 2: Nested CTEs (~15 min) ============ */

-- Task 4: CTE 1: one row per month (DATETRUNC) with the month's total sales.
-- CTE 2: built on CTE 1, adds the previous month's total sales (LAG).
-- Main query: month, total sales, previous month's sales and the change in percent
-- (DECIMAL, 2 decimals, protected against division by zero).
with cte_month_total_sales as
(
	select
		datetrunc(month, orderdate) as month_date,
		sum(sales) as total_sales
	from sales.orders
	group by datetrunc(month, orderdate)
)
, cte_previous_month_total_sales as
(
	select
		month_date,
		total_sales,
		lag(total_sales) over(order by month_date) as pvm_total_sales
	from cte_month_total_sales
)
select
	month_date,
	total_sales,
	pvm_total_sales,
	case
		when pvm_total_sales is null or pvm_total_sales = 0 then null
		else cast(100.0 * (total_sales - pvm_total_sales) / pvm_total_sales as decimal(10, 2))
	end as change_percent
from cte_previous_month_total_sales;

-- Task 5: Show the single most expensive product of each category (one row per category):
-- category, product, price. Use a CTE with ROW_NUMBER.
with cte_product as
(
	select
		category,
		product,
		price,
		row_number() over(partition by category order by price desc) as row_category
	from sales.products
)
, cte_most_expensive_product as 
(
	select
		category,
		product,
		price
	from cte_product
	where row_category = 1
)
select * from cte_most_expensive_product;

-- Task 6 (answer as a comment):
-- a) Name two reasons to write a CTE instead of a subquery.
-- b) If the main query uses the same CTE twice, how many times is it calculated? Is the result stored?
-- 1-reason is to use cte table multiple time 2-reason is readable code
-- cte do not stored, sql server puts it as view in request, if cte used 2 times then it also calculates 2 times,
-- if result needs to store then uses #table

/* ============ Part 3: Recursive CTEs (~20 min) ============ */

-- Task 7 (real data engineering use case: a date spine):
-- Generate every date from 2025-01-01 to 2025-01-31 with a recursive CTE (use DATEADD).
-- Then show each date and that day's total sales from sales.Orders, with 0 for days without orders.
with cte_month_days as
(
	select
		cast('2025-01-01' as date) as date_by_day
	union all
	select
		dateadd(day, 1, date_by_day)
	from cte_month_days
	where date_by_day < eomonth(date_by_day)
)
, cte_total_sales as 
(
	select
		date_by_day,
		coalesce(sum(sales), 0) as total_sales
	from cte_month_days as cmd
	left join sales.orders as s
		on cmd.date_by_day = s.orderdate
	group by date_by_day
)
select * from cte_total_sales;

-- Task 8: Show the employee hierarchy: employeeid, firstname, level and the firstname of the employee's manager
-- (NULL for the top manager).
-- Hint: if you get a type error, remember the CASE rule about compatible types.
with cte_employee_hierarchy as
(
	select
		employeeid,
		firstname,
		1 as level,
		case when managerid is null then null else firstname end as manager_firstname
	from sales.employees
	where managerid is null
	union all
	select
		e.employeeid,
		e.firstname,
		ceh.level + 1,
		ceh.firstname
	from sales.employees as e
	inner join cte_employee_hierarchy as ceh
		on ceh.employeeid = e.managerid
)
select * from cte_employee_hierarchy;

-- Task 9 (answer as a comment):
-- a) What happens if you remove the WHERE my_number < 20 condition from the number series? Which error do you get?
-- b) What does OPTION (MAXRECURSION 0) do, and why is it dangerous?
-- a) it outs of recursion limit, by default its 100 and shows this error: The statement terminated. 
-- The maximum recursion 100 has been exhausted before statement completion.
-- b) it goes to infinity recursion cycle

/* ============ Bonus ============ */

-- Bonus: Extend Task 8 with a path column that shows the chain from the top manager to the employee,
-- for example: 'Frank > Kevin > Michael'.
with cte_employee_hierarchy as
(
	select
		employeeid,
		firstname,
		1 as level,
		case when managerid is null then null else firstname end as manager_firstname,
		cast(firstname as varchar(100)) as top_manager_to_emloyee
	from sales.employees
	where managerid is null
	union all
	select
		e.employeeid,
		e.firstname,
		ceh.level + 1,
		ceh.firstname,
		cast(concat(ceh.top_manager_to_emloyee, ' > ', e.firstname) as varchar(100)) as top_manager_to_emloyee
	from sales.employees as e
	inner join cte_employee_hierarchy as ceh
		on ceh.employeeid = e.managerid
)
select * from cte_employee_hierarchy;