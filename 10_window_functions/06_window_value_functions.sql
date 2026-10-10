/* Lag() & Lead() */
-- analyze the month-over-month performance by finding the percentage change
-- in sales between current and previous months
select
	*,
	current_month_sales - previous_month_sales as m_over_m_change,
	round(cast(current_month_sales - previous_month_sales as decimal(10, 2)) / previous_month_sales * 100, 1) as m_over_percent
from (
	select
		month(orderdate) as order_month,
		sum(sales) current_month_sales,
		lag(sum(sales)) over(order by month(orderdate)) previous_month_sales
	from sales.orders
	group by month(orderdate)
)t

-- in order to analyze customer loyalty,
-- rank customers based on the average days between their orders
select
	customerid,
	avg(days_until_next_order) as avg_days,
	rank() over(order by coalesce(avg(days_until_next_order), 99999999)) as rank_avg
from (
	select
		orderid,
		customerid,
		orderdate as current_order,
		lead(orderdate) over(partition by customerid order by orderdate) as next_order,
		datediff(day, orderdate, lead(orderdate) over(partition by customerid order by orderdate)) days_until_next_order
	from sales.orders
)t
group by customerid

-- find the lowest and highest sales for each product
-- find the difference in sales between current and lowest sales
select
	orderid,
	productid,
	sales,
	first_value(sales) over(partition by productid order by sales) lowest_sales,
	last_value(sales) over(partition by productid order by sales rows between current row and unbounded following) as highest_sales,
	sales - first_value(sales) over(partition by productid order by sales) sales_difference
from sales.orders