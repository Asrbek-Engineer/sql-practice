-- ============================================================
-- SQL FINAL TEST  (~100 min, one sitting)
-- Corrections are marked with:  -- FIX:
-- ============================================================
USE SalesDB;
GO

/* ============ Section A: Basics ============ */

-- A1: Show customers from Germany or the USA whose score is above 500 or missing.
-- Sort by score from highest to lowest, customers with a missing score last.
select
	*
from sales.customers
where (score > 500 or score is null) and country in ('Germany', 'USA')
order by
	case when score is null then 1 else 0 end,
	score desc;

-- A2: For each product category, show the number of orders and the total sales.
-- Keep only the categories with total sales above 100.
-- columns: category, nr_of_orders, total_sales
-- FIX: the category column was missing (write the columns comment from the TASK text, not from your code)
select
	p.category,
	count(s.orderid) as nr_of_orders,
	sum(s.sales) as total_sales
from sales.products as p
left join sales.orders as s
	on s.productid = p.productid
group by p.category
having sum(s.sales) > 100;

-- A3: For each order, show orderid, the order month formatted as 'MMM yyyy',
-- the number of days between orderdate and shipdate, and a label.
-- columns: orderid, order_month, nr_of_days, label
select
	orderid,
	format(orderdate, 'MMM yyyy') as order_month,
	nr_of_days_between,
	case
		when nr_of_days_between is null then 'Not shipped'
		when nr_of_days_between <= 7 then 'Fast'
		else 'Slow'
	end as label
from
(
	select
		*,
		datediff(day, orderdate, shipdate) as nr_of_days_between
	from sales.orders
)t;

-- A4: Customers who have never placed an order, two ways.
-- 1) LEFT JOIN
select
	c.customerid
from sales.customers as c
left join sales.orders as o
	on c.customerid = o.customerid
where o.customerid is null;

-- 2) set operator
select customerid from sales.customers
except
select customerid from sales.orders;

-- A5: employeeid, full name in upper case and its length, only first names starting with 'M'.
-- columns: employeeid, full_name, length_full_name
-- FIX: DATALENGTH returns BYTES (nvarchar = 2 bytes per character) -> use LEN on the same full name
select
	employeeid,
	full_name,
	len(full_name) as length_full_name
from
(
	select
		employeeid,
		upper(concat(trim(firstname), ' ', trim(lastname))) as full_name
	from sales.employees
)t
where full_name like 'M%';

/* ============ Section B: Window functions ============ */

-- B1: order's share of the customer's total in percent.
-- columns: orderid, customerid, sales, total_sales, share_percent
select
	orderid,
	customerid,
	sales,
	sum(sales) over(partition by customerid) as total_sales,
	cast(100.0 * sales / sum(sales) over(partition by customerid) as decimal(10, 2)) as share_percent
from sales.orders;

-- B2: the 2 highest-sales orders of each product.
-- Comment: RANK can return MORE than 2 rows per product when orders share the same sales value
-- (a tie on 1st or 2nd place); ROW_NUMBER always returns exactly 2.
select
	*
from
(
	select
		orderid,
		productid,
		sales,
		row_number() over(partition by productid order by sales desc) as rn
	from sales.orders
)t
where rn <= 2;

-- B3: one row per month (real date): total sales, previous month, change in percent.
-- columns: order_month, total_sales, pm_total_sales, change_percent
-- FIX: the month column was missing; the first month must be NULL (no previous month), not 0
select
	order_month,
	total_sales,
	pm_total_sales,
	cast(100.0 * (total_sales - pm_total_sales) / nullif(pm_total_sales, 0) as decimal(10, 2)) as change_percent
from
(
	select
		datetrunc(month, orderdate) as order_month,
		sum(sales) as total_sales,
		lag(sum(sales)) over(order by datetrunc(month, orderdate)) as pm_total_sales
	from sales.orders
	group by datetrunc(month, orderdate)
)t
order by order_month;

-- B4: moving average of the current and the 2 previous orders.
select
	orderid,
	orderdate,
	sales,
	cast(avg(cast(sales as decimal(10, 2))) over(order by orderdate, orderid
		rows between 2 preceding and current row) as decimal(10, 2)) as avg_sales
from sales.orders;

-- B5: FIX: without a frame, ORDER BY uses RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.
-- RANGE treats rows with the same orderdate as one group (peers), so the sum includes ALL rows
-- up to that date, including every row with the same orderdate -> those rows show the same sum.

/* ============ Section C: Subquery and CTE ============ */

-- C1: products whose price is above the average price of their own category (subquery).
select
	p.*,
	p1.avg_price
from sales.products as p
join (
	select
		category,
		cast(avg(cast(price as decimal(10, 2))) as decimal(10, 2)) as avg_price
	from sales.products
	group by category
) as p1
	on p1.category = p.category
where p.price > p1.avg_price;

-- C2: customer segments with a CTE.
with cte_customers as
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
	coalesce(cc.total_sales, 0) as total_sales,
	case
		when cc.total_sales is null then 'No orders'
		when cc.total_sales >= 100 then 'High'
		when cc.total_sales >= 50 then 'Medium'
		else 'Low'
	end as segment
from sales.customers as c
left join cte_customers as cc
	on c.customerid = cc.customerid;

-- C3: employee hierarchy with level and path (recursive CTE).
with cte_employee_path as
(
	select
		employeeid,
		firstname,
		1 as level,
		cast(firstname as varchar(max)) as top_path
	from sales.employees
	where managerid is null
	union all
	select
		e.employeeid,
		e.firstname,
		cep.level + 1,
		cep.top_path + ' > ' + cast(e.firstname as varchar(max))
	from sales.employees as e
	join cte_employee_path as cep
		on e.managerid = cep.employeeid
)
select * from cte_employee_path;

-- C4: customers with at least one order above 50 (EXISTS).
select
	*
from sales.customers as c
where exists (
	select 1
	from sales.orders as o
	where o.customerid = c.customerid and o.sales > 50
);
go

/* ============ Section D: Views, CTAS, Stored procedures ============ */

-- D1: monthly view (re-runnable).
create or alter view sales.v_test_monthly as
select
	datetrunc(month, orderdate) as order_month,
	count(*) as nr_of_orders,
	sum(sales) as total_sales
from sales.orders
group by datetrunc(month, orderdate);
go

select * from sales.v_test_monthly
order by order_month;

-- D2: top 3 customers by total sales with CTAS (re-runnable), then drop.
drop table if exists sales.test_top_customers;
go

with cte_total_sales as
(
	select
		customerid,
		sum(sales) as total_sales,
		row_number() over(order by sum(sales) desc) as rn
	from sales.orders
	group by customerid
)
select
	c.*,
	cts.total_sales
into sales.test_top_customers
from sales.customers as c
join cte_total_sales as cts
	on cts.customerid = c.customerid
where cts.rn <= 3;

select * from sales.test_top_customers order by total_sales desc;

drop table sales.test_top_customers;
go

-- D3: procedure with parameter, PRINT and TRY / CATCH.
-- FIX: total quantity = SUM(quantity), not COUNT(quantity) (COUNT counts rows)
-- FIX: @category is already nvarchar, no CAST needed (CAST without length cuts to 30 characters)
create or alter procedure sales.get_category_sales @category nvarchar(50) = 'Accessories' as
begin
	begin try
		declare @nr_of_products int;

		select @nr_of_products = count(*)
		from sales.products
		where category = @category;

		print 'Number of products in ' + @category + ': ' + cast(@nr_of_products as nvarchar(10));

		select
			p.product,
			sum(o.quantity) as total_quantity,
			sum(o.sales) as total_sales
		from sales.products as p
		join sales.orders as o
			on o.productid = p.productid
		where p.category = @category
		group by p.product;
	end try
	begin catch
		print 'Error Message: ' + error_message();
	end catch
end
go

exec sales.get_category_sales @category = 'Clothing';
exec sales.get_category_sales;
go

/* ============ Section E: Theory ============ */

-- E1: FIX:
--   1) A table can have only ONE clustered index, but many nonclustered indexes.
--   2) A clustered index sorts and stores the table rows themselves (leaf level = data pages);
--      a nonclustered index is a separate structure whose leaf level points to the rows (RID or clustered key).
--   (A clustered index does not have to be on the primary key or be unique.)

-- E2: rowstore for OLTP (many small reads/writes of single rows, e.g. banking transactions);
--     columnstore for OLAP / DWH (aggregations over millions of rows, high compression).

-- E3: FIX: a Scan reads all pages of the table/index; a Seek uses the B-tree to go directly
--     to the matching rows only. For WHERE lastname = 'Brown':
--     create nonclustered index idx_customers_lastname on sales.customers (lastname);

-- E4: b and c. The index starts with country (leftmost prefix rule); the order of the
--     conditions in WHERE does not matter, so c can seek on country and then on score.

-- E5: FIX: a trigger is code that runs AUTOMATICALLY when an INSERT, UPDATE or DELETE happens on a table.
--     Data engineers avoid it: the logic is hidden from the pipeline, hard to debug, and slows bulk loads.

-- E6: CTE: break one query into readable steps.
--     View: reusable, always up-to-date logic / security layer (stores no data).
--     Temp table: store intermediate results during a session (staging).
--     CTAS table: store a persistent snapshot, e.g. when a view is too slow.

/* ============ Cleanup ============ */
drop view if exists sales.v_test_monthly;
drop procedure if exists sales.get_category_sales;
go

