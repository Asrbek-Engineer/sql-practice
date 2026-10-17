-- Stored Procedures practice (~35 min)
-- Database: SalesDB
-- Before you submit, check 3 things:
--   1) Columns: is every column the task asks for in the result?  (write "-- columns: ..." before each query)
--   2) Division: before every / or AVG, is the column an INT? If so, CAST it first.
--   3) Full run: run the WHOLE file once from top to bottom (F5). It must run twice without errors.
-- Procedure rules: GO before and after every CREATE OR ALTER PROCEDURE; always write the schema (sales.).
USE SalesDB;
GO

/* ============ Part 1: Parameters and multiple statements (~10 min) ============ */

-- Task 1: Create the procedure sales.get_country_report with the parameter @country (default 'USA').
-- It returns TWO result sets:
--   1) the number of customers and the average score (DECIMAL, 2 decimals) of that country,
--   2) the number of orders and the total sales of the customers from that country.
-- Execute it once for 'Germany' and once with the default.
-- columns: 1) nr_of_customers, avg_score, 2) nr_of_orders, total_sales
create or alter procedure sales.get_country_report @country nvarchar(50) = 'USA' as
begin
	-- customers summary
	select 
		count(*) as nr_of_customers,
		avg(cast(score as decimal(10, 2))) as avg_score
	from sales.customers
	where country = @country;

	-- orders summary
	select 
		count(o.orderid) as nr_of_orders,
		sum(sales) as total_sales
	from sales.customers as c
	join sales.orders as o
		on o.customerid = c.customerid
	where c.country = @country;
end
go

exec sales.get_country_report;
exec sales.get_country_report @country = 'Germany';

/* ============ Part 2: Variables and IF / ELSE (~10 min) ============ */

-- Task 2: Change the procedure from Task 1 (CREATE OR ALTER):
-- before the two result sets, store the number of customers of @country in a variable,
-- and PRINT a message like: 'Customers in Germany: 2'.
-- columns: 1) nr_of_customers, avg_score, 2) nr_of_orders, total_sales
go
create or alter procedure sales.get_country_report @country nvarchar(50) = 'USA' as
begin
	-- variables
	declare @nr_of_customers int;
	select
		 @nr_of_customers = count(*)
	from sales.customers
	where country = @country;
	print 'Customers in ' + @country + ': ' + cast(@nr_of_customers as nvarchar);
	-- customers summary
	select
		 count(*) as nr_of_customers,
		avg(cast(score as decimal(10, 2))) as avg_score
	from sales.customers
	where country = @country;

	-- orders summary
	select 
		count(o.orderid) as nr_of_orders,
		sum(sales) as total_sales
	from sales.customers as c
	join sales.orders as o
		on o.customerid = c.customerid
	where c.country = @country;
end
go

exec sales.get_country_report;
exec sales.get_country_report @country = 'Germany';

-- Task 3: In the same procedure, check whether any customer of @country has a missing score.
-- IF yes: PRINT 'Warning: NULL scores found in Germany'
-- ELSE:   PRINT 'All scores are filled in Germany'
-- Do not change any data.
-- columns: 1) nr_of_customers, avg_score, 2) nr_of_orders, total_sales
go
create or alter procedure sales.get_country_report @country nvarchar(50) = 'USA' as
begin
	if exists(select 1 from sales.customers where country = @country and score is null)
	begin
		print 'Warning: NULL scores found in ' + @country;
	end

	else
	begin
		print 'All scores are filled in ' + @country;
	end;

	-- variables
	declare @nr_of_customers int;
	select
		 @nr_of_customers = count(*)
	from sales.customers
	where country = @country;
	print 'Customers in ' + @country + ': ' + cast(@nr_of_customers as nvarchar);
	-- customers summary
	select
		 count(*) as nr_of_customers,
		avg(cast(score as decimal(10, 2))) as avg_score
	from sales.customers
	where country = @country;

	-- orders summary
	select 
		count(o.orderid) as nr_of_orders,
		sum(sales) as total_sales
	from sales.customers as c
	join sales.orders as o
		on o.customerid = c.customerid
	where c.country = @country;
end
go

exec sales.get_country_report;
exec sales.get_country_report @country = 'Germany';

/* ============ Part 3: Error handling (~10 min) ============ */

-- Task 4: Create the procedure sales.test_error_handling.
-- Inside TRY, run a query that divides by zero. In CATCH, PRINT the error number and the error message.
-- Execute it.
-- Comment: what would happen if there were no TRY / CATCH?
go
create or alter procedure sales.test_error_handling as
begin
	begin try
		select
			1 / 0
	end try

	begin catch
		print 'Error Number: ' + cast(error_number() as nvarchar(10));
		print 'Error Message: ' + error_message();
	end catch
end
go
-- if there were no try catch then it returns error message

exec sales.test_error_handling

-- Task 5 (answer as a comment):
-- a) Name two differences between a view and a stored procedure.
-- b) Next week you will build a data warehouse. Why would a data engineer put each load step
--    (for example: "load the bronze layer") into its own stored procedure?
-- a) in stored procedure there can be used multiple statements in a query and can handle errors, add variables and other programming functions
-- b) it is architecture layers that appropriate and essential for data ware house i guess

/* ============ Bonus ============ */

-- Bonus: Add timing to sales.get_country_report: store the start time in a variable at the beginning,
-- and at the end PRINT how many milliseconds the procedure took.
-- columns: 1) nr_of_customers, avg_score, 2) nr_of_orders, total_sales
go
create or alter procedure sales.get_country_report @country nvarchar(50) = 'USA' as
begin
	-- variables
	declare @start_time datetime2 = sysdatetime();
	declare @nr_of_customers int;
	if exists(select 1 from sales.customers where country = @country and score is null)
	begin
		print 'Warning: NULL scores found in ' + @country;
	end

	else
	begin
		print 'All scores are filled in ' + @country;
	end;

	select
		 @nr_of_customers = count(*)
	from sales.customers
	where country = @country;
	print 'Customers in ' + @country + ': ' + cast(@nr_of_customers as nvarchar);
	-- customers summary
	select
		 count(*) as nr_of_customers,
		avg(cast(score as decimal(10, 2))) as avg_score
	from sales.customers
	where country = @country;

	-- orders summary
	select 
		count(o.orderid) as nr_of_orders,
		sum(sales) as total_sales
	from sales.customers as c
	join sales.orders as o
		on o.customerid = c.customerid
	where c.country = @country;

	declare @duration_ms int = datediff(millisecond, @start_time, sysdatetime());
	print 'Execution Time: ' + cast(@duration_ms as nvarchar) + ' ms';
end
go

exec sales.get_country_report;
exec sales.get_country_report @country = 'Germany';

/* ============ Cleanup ============ */
-- Drop the procedures you created in this file and the old get_customer_summary from the lesson.
drop procedure if exists sales.get_country_report;
drop procedure if exists sales.test_error_handling;
drop procedure if exists [dbo].[get_customer_summary];
