select
	distinct TABLE_NAME
from information_schema.columns;

/* from subquery */
-- find the products that have a price higher than the average price of all products
-- main query
select
	*
from (
	-- sub query
	select
		productid,
		price,
		avg(price) over() avg_price
	from sales.products
)t
where price > avg_price;

-- rank customers based on their total amount of sales
-- main query
select
	*,
	rank() over(order by total_sales desc) customer_rank
from (
	-- subquery
	select
		customerid,
		sum(sales) as total_sales
	from sales.orders
	group by customerid
)t;

/* select subquery */
-- rule: the result of select subquery have to be scalar
-- show the product ids, product names, prices and the total number of orders
-- main query
select
	productid,
	product,
	price,
	-- subquery
	(select count(*) from sales.orders) as total_orders
from sales.products;

/* join subquery */
-- show all customer details and find the total orders of each customer
-- main query
select
	c.*,
	o.total_orders
from sales.customers as c
-- subquery
left join (
	select
		customerid,
		count(*) as total_orders
	from sales.orders
	group by customerid
) as o
	on c.customerid = o.customerid;

/* where subquery */
-- rule: what the WHERE subquery must return depends on the operator:
--   =, >, <, >=, <=, <>  -> scalar (one value)
--   IN, NOT IN, ANY, ALL -> one column, many rows (a list)
--   EXISTS, NOT EXISTS   -> anything; only "is there at least one row?" matters
-- main query
select
	productid,
	price,
	(select avg(price) from sales.products) as avg_price
from sales.products
-- subquery
where price > (select avg(price) from sales.products);

-- subquery using in & not in operators
-- show the details of orders made by customers in Germany
-- main query
select
	*
from sales.orders
-- sub query
where customerid in(
				select
					customerid
				from sales.customers
				where country = 'Germany'
				);

-- trap: if the NOT IN list contains a NULL, the query returns no rows
-- (x <> NULL is UNKNOWN, so the whole NOT IN is never TRUE). Prefer NOT EXISTS.

-- subquery using any operator
-- find female employees whose salaries are greater
-- than the salaries of any male employees
-- main query
select
	employeeid,
	firstname,
	salary
from sales.employees
-- subquery
where gender = 'F' and salary > any (select salary from sales.employees where gender = 'M');

-- subquery using all operator
-- find female employees whose salaries are greater
-- than the salaries of all male employees
-- main query
select
	employeeid,
	firstname,
	salary
from sales.employees
-- subquery
where gender = 'F' and salary > all (select salary from sales.employees where gender = 'M');

-- show all customer details and find the total orders of each customer
-- correlated subquery: the inner query uses a column of the outer query (c.customerid)
-- and runs once for each outer row
-- main query
select
	*,
	-- subquery
	(select count(*) from sales.orders as o where o.customerid = c.customerid) as total_orders
from sales.customers as c;

-- show the details of orders made by customers in Germany
-- main query
select
	*
from sales.orders as o
-- subquery
where exists (
				select 1
				from sales.customers as c
				where c.country = 'Germany' and o.customerid = c.customerid
			);