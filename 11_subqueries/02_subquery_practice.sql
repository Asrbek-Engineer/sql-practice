-- Subquery practice + review (~65 min)
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

/* ============ Review A: Window Aggregate (+7 days, NO notes) ============ */

-- A1: Show orderid, customerid, sales and the customer's average sales (DECIMAL, 2 decimals).
-- Keep only the orders whose sales are above their customer's average.
select
	*
from (
	select 
		orderid,
		customerid,
		sales,
		cast(avg(cast(sales as decimal(10, 2))) over(partition by customerid) as decimal(10, 2)) as avg_sales
	from sales.orders
)t
where sales > avg_sales;

-- A2: Show orderid, customerid, orderdate, sales and a running total of sales for each customer,
-- ordered by orderdate (write the frame and a tie-breaker).
select 
	orderid,
	customerid,
	orderdate,
	sales,
	sum(sales) over(partition by customerid order by orderdate, orderid rows between unbounded preceding and current row) as running_total_sales
from sales.orders;

/* ============ Review B: Strings and set operators (mixed, NO notes) ============ */

-- B1: Show customerid and the customer's full name (firstname + space + lastname) in upper case.
-- A missing lastname must not turn the whole name into NULL.
select
	customerid,
	upper(concat(firstname, ' ', lastname)) as full_name
from sales.customers;

-- B2: Show a list of first names that appear in BOTH sales.Customers and sales.Employees.
-- Then, in a second query, show all first names from both tables without duplicates.
-- appear in both
select
	firstname
from sales.customers
intersect
select
	firstname
from sales.employees;

-- without duplicates
select
	firstname
from sales.customers
union
select
	firstname
from sales.employees;

/* ============ Part 1: Subquery in FROM, SELECT and JOIN (~15 min) ============ */

-- Task 1: Show product, category, price and the average price of its category (DECIMAL, 2 decimals).
-- Keep only the products that cost more than their category's average.
select
	*
from (
	select
		product,
		category,
		price,
		cast(avg(cast(price as decimal(10, 2))) over(partition by category) as decimal(10, 2)) as avg_price_by_category
	from sales.products
)t
where price > avg_price_by_category;

-- Task 2: Show productid, product, price, the average price of ALL products,
-- and the difference between the product's price and that average.
-- Use a subquery in SELECT (not a window function).
select
	*,
	price - avg_price as price_difference
from (
	select
		productid,
		product,
		price,
		(select cast(avg(cast(price as decimal(10, 2))) as decimal(10, 2)) from sales.products) avg_price
	from sales.products
)t;

-- Task 3: Show every customer's customerid, firstname, number of orders and total sales.
-- Customers with no orders must appear with 0, not NULL. Use a JOIN to a subquery.
select
	c.customerid,
	c.firstname,
	coalesce(o.nr_of_orders, 0) as nr_of_orders,
	coalesce(o.total_sales, 0) as total_sales
from sales.customers as c
left join (
	select
		customerid,
		count(*) as nr_of_orders,
		sum(sales) as total_sales
	from sales.orders
	group by customerid
) as o
	on c.customerid = o.customerid;

/* ============ Part 2: Subquery in WHERE (~20 min) ============ */

-- Task 4: Show all orders of products from the 'Accessories' category. Use IN.
select
	*
from sales.orders
where productid in (select productid from sales.products where category in ('Accessories'));

-- Task 5: Show the customers who have never placed an order. Use NOT EXISTS.
select
	*
from sales.customers as c
where not exists (select 1 from sales.orders as o where c.customerid = o.customerid);

-- Task 6 (trap): Run this query and look at the result:
--   SELECT * FROM sales.Customers
--   WHERE customerid NOT IN (SELECT customerid FROM sales.Orders UNION ALL SELECT NULL);
-- Comment: why does it return no rows at all?
-- Comment: why does NOT EXISTS (Task 5) not have this problem?
SELECT * FROM sales.Customers
WHERE customerid NOT IN (SELECT customerid FROM sales.Orders UNION ALL SELECT NULL);
-- not in checks every value with and operator if there is even one unknown or false value then returns nothing
-- exists operator gives answer if there is suitable row? gets answer with true or false, if ther is null ignores

-- Task 7: Show employees outside the 'Sales' department whose salary is higher than
-- the salary of EVERY employee in the 'Sales' department.
-- Comment: what would > ALL return if the subquery returned no rows? Why?
-- 1st way
select * 
from sales.employees
where department != 'Sales' and salary > (
	select max(salary)
	from sales.employees
	where department = 'Sales');

-- 2nd way
select * 
from sales.employees
where salary > all (
	select salary
	from sales.employees
	where department = 'Sales');
-- if > all returned no rows then in the main query shows every row of table

/* ============ Part 3: Correlated subquery (~15 min) ============ */

-- Task 8: For each order, show orderid, customerid, sales and the customer's total sales.
-- Use a correlated subquery in SELECT.
-- Comment: which technique from the previous lessons gives the same result,
-- and which one would you choose for a table with 10 million rows? Why?
select
	orderid,
	customerid,
	sales,
	(select sum(sales) from sales.orders as o2 where o1.customerid = o2.customerid) as customer_total_sales
from sales.orders o1;
-- window functions would give same result, I would use window function in order better performance
-- because in correlated subquery each subqueries inner process executes several time for the main queries each row so it slows

-- Task 9: Show each customer's latest order: customerid, orderid, orderdate.
-- Use a correlated subquery in WHERE (no window functions).
select
	customerid,
	orderid,
	orderdate
from sales.orders as o1
where o1.orderdate = (select max(o2.orderdate) from sales.orders as o2 where o1.customerid = o2.customerid);

/* ============ Bonus ============ */

-- Bonus: Show the product with the SECOND highest price, without window functions and without TOP/OFFSET.
-- If two products share the highest price, the next different price counts as second.
select 
	*
from sales.products
where price = (
				select
					max(price)
				from sales.products
				where price < (select max(price) from sales.products)
			);

