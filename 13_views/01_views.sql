/* views */
use SalesDB;
go

-- rule: CREATE VIEW must be the only statement in its batch -> put GO before and after it
-- rule: if schema is not specified then by default it takes dbo
-- rule: a view stores only the query, not the data; it runs the query every time it is used

-- find the running total of sales for each month
if object_id('sales.v_monthly_summary', 'v') is not null
	drop view sales.v_monthly_summary;
go

create view sales.v_monthly_summary as
(
	select
		datetrunc(month, orderdate) as order_month,
		sum(sales) as total_sales,
		count(orderid) as total_orders,
		sum(quantity) as total_quantity
	from sales.orders
	group by datetrunc(month, orderdate)
);
go

select * from sales.v_monthly_summary;

-- drop view
drop view sales.v_monthly_summary;
go

-- provide view that combines details from orders, products, customers and employees
create view sales.v_order_details as
(
	select
		o.orderid,
		o.orderdate,
		p.product,
		p.category,
		coalesce(c.firstname, '') + ' ' + coalesce(c.lastname, '') as customer_name,
		c.country as customer_country,
		coalesce(e.firstname, '') + ' ' + coalesce(e.lastname, '') as sales_name,
		e.department,
		o.sales,
		o.quantity
	from sales.orders as o
	left join sales.products as p
		on p.ProductID = o.ProductID
	left join sales.customers as c
		on c.CustomerID = o.CustomerID
	left join sales.employees as e
		on e.EmployeeID = o.SalesPersonID
);
go

select * from sales.v_order_details;

-- provide a view for eu sales team
-- that combines details from all tables
-- and excludes data related to the usa
-- note: c.country != 'USA' also removes rows where country is NULL (NULL != 'USA' is UNKNOWN)
create view sales.v_order_details_eu as
(
	select
		o.orderid,
		o.orderdate,
		p.product,
		p.category,
		coalesce(c.firstname, '') + ' ' + coalesce(c.lastname, '') as customer_name,
		c.country as customer_country,
		coalesce(e.firstname, '') + ' ' + coalesce(e.lastname, '') as sales_name,
		e.department,
		o.sales,
		o.quantity
	from sales.orders as o
	left join sales.products as p
		on p.ProductID = o.ProductID
	left join sales.customers as c
		on c.CustomerID = o.CustomerID
	left join sales.employees as e
		on e.EmployeeID = o.SalesPersonID
	where c.country != 'USA'
);
go

select * from sales.v_order_details_eu;