/* Stored Procedure */
-- always use go before and after using create or alter procedure and views
-- begin...end do not shows limit of procedure only batch decides 
-- step 1: write a query
-- for us customers find the total number of customers and the average sales
select 
	count(*) as total_customers,
	cast(avg(cast(score as decimal(10, 2))) as decimal(10, 2)) as avg_score
from sales.customers
where country = 'USA'

-- step 2: turing the query into a stored procedure
create procedure get_customer_summary as
begin
	select 
		count(*) as total_customers,
		cast(avg(cast(score as decimal(10, 2))) as decimal(10, 2)) as avg_score
	from sales.customers
	where country = 'USA'
end
go

-- step 3: execute the stored procedure
exec get_customer_summary

-- Parametres
-- define stored procedure
create or alter procedure get_customer_summary @country nvarchar(50) = 'USA' -- default input
as
begin
	select 
		count(*) as total_customers,
		cast(avg(cast(score as decimal(10, 2))) as decimal(10, 2)) as avg_score
	from sales.customers
	where country = @country;

	-- find the total nr. of orders and sales
	select
		count(orderid) as nr_of_orders,
		sum(sales) as total_sales
	from sales.orders as o
	join sales.customers as c
		on c.customerid = o.customerid
	where c.country = @country;
end
go

-- execute the stored procedure
exec get_customer_summary @country = 'Germany'
-- by default @country is USA
exec get_customer_summary

-- Variables & If Else & Error Handling & Styling
create or alter procedure get_customer_summary @country nvarchar(50) = 'USA' as
begin
	begin try
		-- ================
		-- declare variable
		-- ================
		declare @total_customers int, @avg_score decimal(10, 2);

		-- ======================
		-- prepare & cleanup data
		-- ======================
		if exists(select 1 from sales.customers where score is null and country = @country)
		begin
			print 'Updating NULL scores to 0';
			update sales.customers
			set score = 0
			where score is null and country = @country;
		end

		else
		begin
			print 'No NULL scores found'
		end;
		-- ==================
		-- generating reports
		-- ==================
		-- calculate total customers and average score for specific country
		select
			@total_customers = count(*),
			@avg_score = cast(avg(cast(score as decimal(10, 2))) as decimal(10, 2))
		from sales.customers
		where country = @country;

		print 'Total Customers from ' + @country + ': ' + cast(@total_customers as nvarchar);
		print 'Average score from ' + @country + ': ' + cast(@avg_score as nvarchar);

		-- calculate total number of orders and total sales for specific country
		select
			-- 1 / 0, -- error
			count(orderid) as nr_of_orders,
			sum(sales) as total_sales
		from sales.orders as o
		join sales.customers as c
			on c.customerid = o.customerid
		where c.country = @country;
	end try

	begin catch
		-- ==============
		-- error handling
		-- ==============
		print 'An error occured.';
		print 'Error Message: ' + error_message();
		print 'Error Number: ' + cast(error_number() as nvarchar);
		print 'Error Line: ' + cast(error_line() as nvarchar);
		print 'Error Procedure: ' + error_procedure();
	end catch
end
go

exec get_customer_summary @country = 'Germany'
exec get_customer_summary

/* Triggers */
create table sales.employee_logs (
	logid int identity(1,1) primary key,
	employee_id int,
	log_message varchar(255),
	log_date date
)
go

create or alter trigger trg_after_insert_employee on sales.employees
after insert as
begin
	insert into sales.employee_logs (employee_id, log_message, log_date)
	select
		employeeid,
		'New Employee Added = ' + cast(employeeid as varchar),
		getdate()
	from inserted;
end
go

insert into sales.employees
values
(7, 'Maria', 'Doe', 'HR', '1988-01-12', 'F', 80000, 3);

select * from sales.employee_logs;

