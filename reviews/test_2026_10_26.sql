-- ============================================================
-- Topics: NULL logic, COUNT, RANGE frame, ROW_NUMBER,
--         stored procedure + batch, DWH theory
-- Corrections are marked with:  -- FIX:
-- ============================================================
USE SalesDB;
GO

/* ============ Section A: Queries ============ */

-- A1 (NULL logic): customers who have never placed an order (NOT EXISTS).
-- columns: customerid, firstname
select
	customerid,
	firstname
from sales.customers as c
where not exists (select 1 from sales.orders as o where o.customerid = c.customerid);

-- Why can NOT IN return no rows at all?
--   x NOT IN (1, 2, NULL)  =  x <> 1 AND x <> 2 AND x <> NULL
--   x <> NULL is UNKNOWN (not TRUE), so the whole condition is never TRUE -> no rows.
--   It happens as soon as the subquery returns at least ONE NULL.
--   NOT EXISTS does not have this problem.

-- A2 (COUNT): customers per country, with and without a score.
-- columns: country, nr_customers, nr_with_score, nr_missing_score
select
	country,
	count(*) as nr_customers,                                   -- COUNT(*) counts rows
	count(score) as nr_with_score,                              -- COUNT(column) skips NULLs
	count(case when score is null then 0 end) as nr_missing_score
from sales.customers
group by country;

-- A3 (RANGE vs ROWS frame)
-- columns: orderid, orderdate, sales, running_total_default, running_total_rows
select
	orderid,
	orderdate,
	sales,
	sum(sales) over(order by orderdate) as running_total_default,
	sum(sales) over(order by orderdate rows between unbounded preceding and current row) as running_total_rows
from sales.orders;

-- FIX (more precise comment):
--   With ORDER BY and no frame, the default frame is
--   RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.
--   RANGE treats all rows with the SAME orderdate as one group (peers):
--   each of them gets the sum up to the end of that date, so they all show the same value.
--   Later dates are NOT included.
--   ROWS counts physical rows one by one, so every row gets its own running total.
--   The two columns differ only on rows that share an orderdate with another row.

-- A4 (ROW_NUMBER, dedup like in Silver): latest order per customer.
-- columns: customerid, orderid, orderdate, sales
-- FIX: "for each customer" -> partition by customerid (not orderdate);
--      tie on orderdate -> second sort key orderid desc
select
	customerid,
	orderid,
	orderdate,
	sales
from (
	select
		customerid,
		orderid,
		orderdate,
		sales,
		row_number() over(partition by customerid order by orderdate desc, orderid desc) as rn
	from sales.orders
) t
where rn = 1;

/* ============ Section B: Procedure (DWH pattern) ============ */

if object_id('sales.country_summary', 'U') is not null
	drop table sales.country_summary;
go

create table sales.country_summary (
	country nvarchar(50),
	nr_customers int,
	total_sales int
);
go

create or alter procedure sales.load_country_summary as
begin
	begin try
		declare @start_batch_time datetime2, @end_batch_time datetime2;
		set @start_batch_time = sysdatetime();

		truncate table sales.country_summary;

		insert into sales.country_summary (
			country,
			nr_customers,
			total_sales
		)
		select
			c.country,
			-- FIX: after a JOIN one customer appears once per order -> count(distinct ...)
			count(distinct c.customerid) as nr_customers,
			-- FIX: "their sales = 0" -> coalesce(..., 0); nullif(sales, 0) does the opposite
			coalesce(sum(o.sales), 0) as total_sales
		from sales.customers as c
		-- FIX: "customers without orders must still be counted" -> LEFT JOIN
		left join sales.orders as o
			on o.customerid = c.customerid
		group by c.country;

		set @end_batch_time = sysdatetime();
		print 'Load Duration: ' + cast(datediff(millisecond, @start_batch_time, @end_batch_time) as nvarchar(10)) + ' milliseconds';
	end try

	begin catch
		print 'Error Message: ' + error_message();
		print 'Error Line: ' + cast(error_line() as nvarchar(10));
		throw;   -- FIX: re-throw, so the caller sees that the load failed
	end catch
end
go

exec sales.load_country_summary;

select * from sales.country_summary;   -- FIX: step 3 asked to select from the table

-- cleanup
drop procedure if exists sales.load_country_summary;
drop table if exists sales.country_summary;
go

/* ============ Section C: Theory ============ */

-- C1: Scan vs Seek
--   Scan: reads ALL pages of the table / index, row by row.
--   Seek: uses the B-tree of an index to go DIRECTLY to the matching rows only.
--   Index that turns WHERE lastname = 'Brown' from a Scan into a Seek:
create nonclustered index idx_customers_lastname on sales.customers (lastname);
go

select * from sales.customers where lastname = 'Brown';   -- execution plan: Index Seek (+ Key Lookup)

-- FIX: cleanup, otherwise the second F5 fails ("index already exists")
drop index if exists idx_customers_lastname on sales.customers;
go

-- C2: Clustered vs nonclustered index
-- FIX: a clustered index does NOT have to be on the primary key or unique values.
--   1) A table can have only ONE clustered index, but MANY nonclustered indexes.
--   2) A clustered index sorts and stores the table rows themselves (leaf level = data pages);
--      a nonclustered index is a separate structure whose leaf level points to the rows
--      (RID on a heap, or the clustered key).

-- C3: ALTER DATABASE ... SET SINGLE_USER WITH ROLLBACK IMMEDIATE
-- FIX:
--   SINGLE_USER            -> only ONE connection (yours) may use the database.
--   WITH ROLLBACK IMMEDIATE -> all other connections are disconnected NOW and their
--                              open transactions are rolled back (no waiting).
--   Why before DROP DATABASE: DROP fails with "database is currently in use"
--   while any other connection (another query tab, Object Explorer) is open.
--   Danger: on a production server it kicks out every user without warning.

-- C4: BULK INSERT errors
-- FIX:
--   Error code 32 -> the file is LOCKED by another process (e.g. the CSV is open in Excel).
--                    Fix: close that program (check Task Manager for EXCEL.EXE), run again.
--   Error code 5  -> ACCESS DENIED: the SQL Server service account has no permission
--                    to read the folder. Fix: grant read access with icacls
--                    (or copy the files to a folder the service can read).