-- Window Value Functions practice + review (~60 min)
-- Database: SalesDB
-- Before each query, write the expected columns as a comment.
-- Before you submit, check 6 things:
--   1) Are all the columns the task asks for in the result?
--   2) Is any column used with / or AVG an INT? If so, cast it to DECIMAL first.
--   3) Are you grouping or sorting by a real date, not by text or month number?
--   4) Does each alias describe its value?
--   5) Did you look at 1-2 result rows and check them by eye?
--   6) Did you apply every feedback rule to the whole file?
USE SalesDB;

/* ============ Review 1: Window Basics (+3 days, NO notes) ============ */

-- RB1: Ordered by orderdate, show orderid, orderdate, sales and the sum of
-- the current order's sales and the previous order's sales.
select
	orderid,
	orderdate,
	sales,
	sum(sales) over(order by orderdate rows between 1 preceding and current row) as current_and_previous_sales
from sales.orders;

-- RB2 (answer as a comment): If you write SUM(sales) OVER (ORDER BY orderdate) with no frame,
-- which rows does each sum include?
-- all the rows show sum of sales, works like: sum intially equals 0 and shows in row: sum += sales
-- without frame in default it considers: range between unbounded preceding and current row 
-- so from first row to current row plus same orderdate rows also consideres

/* ============ Review 2: Date functions (+7 days, NO notes) ============ */

-- RD1: Show orderid, orderdate, the last day of the order's month,
-- and how many days are left from orderdate until the end of that month.
select
	orderid,
	orderdate,
	eomonth(orderdate) as end_of_order_month,
	datediff(day, orderdate, eomonth(orderdate)) as days_left 
from sales.orders;

-- RD2: Show orderid and orderdate formatted as 'dd.MM.yyyy', plus the weekday name.
select
	orderid,
	format(orderdate, 'dd.MM.yyyy - dddd') as formatted_order_date
from sales.orders;

/* ============ Part 1: LAG and LEAD (~20 min) ============ */

-- Task 1: Ordered by orderdate, show orderid, orderdate, sales,
-- the previous order's sales and the next order's sales.
select
	orderid,
	orderdate,
	sales,
	lag(sales) over(order by orderdate) previous_sales,
	lead(sales) over(order by orderdate) next_sales
from sales.orders;

-- Task 2: Show LAG(sales) and LAG(sales, 1, 0) side by side.
-- Comment: what is the difference, and when would 0 be misleading in a report?
select
	orderid,
	orderdate,
	sales,
	lag(sales) over(order by orderdate) lag1,
	lag(sales, 1, 0) over(order by orderdate) lag2
from sales.orders
-- null will appear because there is no previous order

-- Task 3 (MoM): Show one row per month (DATETRUNC) with the month's total sales,
-- the previous month's total sales, and the change in percent (DECIMAL, 2 decimals).
-- Protect against division by zero.
select
	*,
	case
		when prev_month_total_sales = 0 then null
		else round(cast(100.0 * (current_month_total_sales - prev_month_total_sales) / prev_month_total_sales as decimal(10, 2)), 2)
	end as change_percent
from (
	select
		*,
		lag(current_month_total_sales) over(order by month_date) prev_month_total_sales
	from  (
		select
			datetrunc(month, orderdate) as month_date,
			sum(sales) current_month_total_sales
		from sales.orders
		group by datetrunc(month, orderdate)
	)t1
)t2;

-- Task 4: Ordered by orderdate, show orderid, sales and a trend column:
-- 'First' for the first order, 'Up' if sales are higher than the previous order,
-- 'Down' if lower, 'Same' if equal.
select
	*,
	case
		when previous_sales is null then 'First'
		when sales > previous_sales then 'Up'
		when sales < previous_sales then 'Down'
		else 'Same'
	end as sales_change
from (
	select
		orderid,
		orderdate,
		sales,
		lag(sales) over(order by orderdate) as previous_sales
	from sales.orders
)t;

/* ============ Part 2: Customer retention (~15 min) ============ */

-- Task 5: For each order, show customerid, orderid, orderdate,
-- the customer's previous order date and how many days passed since that previous order.
select
	customerid,
	orderid,
	orderdate,
	lag(orderdate) over(partition by customerid order by orderdate) as previous_order_date,
	datediff(day, lag(orderdate) over(partition by customerid order by orderdate), orderdate) as days_passed
from sales.orders;

-- Task 6: Using Task 5, show each customer's average number of days between orders (DECIMAL, 2 decimals),
-- sorted from the most frequent buyer to the least frequent. Customers with one order show NULL.
select
	customerid,
	cast((avg(days_passed)) as decimal(10, 2)) as avg_days
from (
	select
		customerid,
		cast(datediff(day, lag(orderdate) over(partition by customerid order by orderdate), orderdate) as decimal(10, 2)) as days_passed
	from sales.orders
)t
group by customerid
order by coalesce(cast((avg(days_passed)) as decimal(10, 2)), 99999999);

/* ============ Part 3: FIRST_VALUE and LAST_VALUE (~15 min) ============ */

-- Task 7: For each order, show productid, orderid, sales, the lowest sales of its product
-- (use FIRST_VALUE) and the difference between the order's sales and that lowest value.
select
	*,
	sales - lowest_sales as sales_difference
from (
	select
		productid,
		orderid, 
		sales,
		first_value(sales) over(partition by productid order by sales) as lowest_sales
	from sales.orders
)t;

-- Task 8 (trap): Run this and look at the result:
--   LAST_VALUE(sales) OVER (PARTITION BY productid ORDER BY sales)
-- Comment: why does it return the current row's sales instead of the highest sales?
-- Then fix it so it returns the highest sales of each product.
select
	productid,
	orderid,
	sales,
	LAST_VALUE(sales) OVER (PARTITION BY productid ORDER BY sales)
from sales.orders;

-- frame ends always in current row by default so last value always be current row
-- fixed solution
select
	productid,
	orderid,
	sales,
	LAST_VALUE(sales) OVER (PARTITION BY productid ORDER BY sales rows between current row and unbounded following) as highest_sales
from sales.orders;

-- Task 9 (answer as a comment): MIN(orderdate) and FIRST_VALUE(orderdate) can give the same date.
-- When can FIRST_VALUE do something that MIN cannot?
-- in first_value() we can return another columen while sorting another one

/* ============ Bonus ============ */

-- Bonus: For each customer, show the orderid of their first order and the orderid of their latest order
-- (one row per customer).
select
	*
from (
	select
		customerid,
		first_value(orderid) over(partition by customerid order by orderdate) as first_order,
		first_value(orderid) over(partition by customerid order by orderdate desc) as latest_order
	from sales.orders
)t
group by t.customerid, t.first_order, t.latest_order;