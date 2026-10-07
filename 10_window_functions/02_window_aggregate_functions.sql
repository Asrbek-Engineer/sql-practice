/* COUNT */
-- find total number of orders
-- find total number of orders for each customers
-- additionally provide details such orderid, orderdate
select
	orderid,
	orderdate,
	customerid,
	count(*) over() as total_orders,
	count(*) over(partition by customerid) as orders_by_customers
from sales.orders;


-- find total number of customers
-- find total number of scores for the customers
-- additionally provide all customers details
select
*,
count(*) over() total_customers_star,
count(1) over() total_customers_one,
count(score) over() total_scores
from sales.customers;

-- check whether the table 'orders' contains any dublicate rows
select *
from 
(
	select
		orderid,
		count(*) over(partition by orderid) check_pk
	from sales.ordersarchive
)t
where check_pk > 1;

/* SUM */
-- find the total sales across all orders
-- and the total sales for each product
-- additionally provide details such orderid, orderdate
select 
	orderid,
	orderdate,
	sales,
	productid,
	sum(sales) over() total_sales,
	sum(sales) over(partition by productid) sales_by_products
from sales.orders;

-- find the percentage contribution of each order's sales to the total sales
select
	orderid,
	orderdate,
	sales,
	sum(sales) over() as total_sales,
	round(cast(sales as decimal) / sum(sales) over() * 100, 2) as percentage_of_total
from sales.orders

/* AVG */
-- find the average sales across all orders
-- and the average sales for each product
-- additionally provide details such orderid, orderdate
select
	orderid,
	orderdate,
	sales,
	productid,
	avg(cast(sales as decimal(10, 2))) over() as avg_sales,
	avg(cast(sales as decimal(10, 2))) over(partition by productid) as avg_sales_by_products
from sales.orders

-- find the average scores of customers
-- additionally provide details such customerid and lastname
select
	customerid,
	lastname,
	score,
	coalesce(score, 0) as score_without_null,
	avg(score) over() avg_score,
	avg(coalesce(score, 0)) over() avg_score_without_null
from sales.customers;

-- find all orders where sales are higher than the average sales across all orders
select
*
from
(
	select
		orderid,
		sales,
		avg(coalesce(sales, 0)) over() as avg_sales
	from sales.orders
)t
where sales > avg_sales;

/* MIN, MAX */
-- show the employees who have the lowest and highest salaries
select
*
from
(
	select
	*,
	min(salary) over() as lowest_salary,
	max(salary) over() as highest_salary
	from sales.employees
)t
where salary in (lowest_salary, highest_salary);

-- find the deviation of each sales from the minimum and maximum sales amounts
select
	orderid,
	orderdate,
	productid,
	sales,
	min(sales) over() as lowest_sales,
	max(sales) over() as highest_sales,
	sales - min(sales) over() as deviation_from_min,
	max(sales) over() - sales as deviation_from_max
from sales.orders;

-- Running total
select
	orderid,
	orderdate,
	sales,
	sum(sales) over(order by orderdate rows between unbounded preceding and current row) as running_total_sales
from sales.orders;

-- Rolling total
select
	orderid,
	datetrunc(month, orderdate) as montT_start,
	sum(sum(sales)) over(order by datetrunc(month, orderdate) rows between 2 preceding and current row) as rolling_total_sales
from sales.orders
group by orderid, datetrunc(month, orderdate);

-- calculate moving average of sales for each product over time
-- calculate moving average of sales for each product over time, including only the next order
select
	orderid,
	productid,
	orderdate,
	sales,
	avg(cast(sales as decimal)) over(partition by productid) as avg_by_product,
	avg(cast(sales as decimal)) over(partition by productid order by orderdate rows between unbounded preceding and current row) as moving_avg,
	avg(cast(sales as decimal)) over(partition by productid order by orderdate rows between current row and 1 following) as rolling_avg
from sales.orders;

