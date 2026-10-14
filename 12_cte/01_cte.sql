/* cte - common table expression */
use SalesDB;

-- step1: find the total sales per customer (standalone cte)
with cte_total_sales as 
(
	select 
		customerid,
		sum(sales) as total_sales
	from sales.orders
	group by customerid
	-- rule: order by not allowed in cte
)
-- step2: find the last order date for each customer (standalone cte)
, cte_last_order as
(
	select
		customerid,
		max(orderdate) as last_order
	from sales.orders
	group by customerid
)
-- step3: rank customers based on total sales per customer (nested cte)
, cte_customer_rank as
(
	select
		customerid,
		total_sales,
		rank() over(order by total_sales desc) as customer_rank
	from cte_total_sales
)
-- step4: segment customers based on their total sales (nested cte)
, cte_customer_segments as
(
	select
	customerid,
	total_sales,
	case
		when total_sales > 100 then 'High'
		when total_sales > 80 then 'Medium'
		else 'Low'
	end as customer_segments
	from cte_total_sales
)
-- main query
select
	c.customerid,
	c.firstname,
	c.lastname,
	cts.total_sales,
	clo.last_order,
	ccr.customer_rank,
	ccs.customer_segments
from sales.customers as c
left join cte_total_sales as cts
	on cts.customerid = c.customerid
left join cte_last_order as clo
	on clo.customerid = c.customerid
left join cte_customer_rank as ccr
	on ccr.customerid = c.customerid
left join cte_customer_segments as ccs
	on ccs.customerid = c.customerid;

/* recursive cte */
-- generate a sequence of numbers from 1 to 20
with cte_series as
(
	-- anchor query
	select
		1 as my_number
	union all
	-- recursive query
	select
		my_number + 1
	from cte_series
	where my_number < 20
)
-- main query
select * from cte_series
option (maxrecursion 1000);

-- show the employee hierarchy by displaying each employee's level within the organization
with cte_emp_hierarchy as
(
	-- anchor query
	select
		employeeid,
		firstname,
		managerid,
		1 as level
	from sales.employees
	where managerid is null
	union all
	-- recursive query
	select
		e.employeeid,
		e.firstname,
		e.managerid,
		ceh.level + 1
	from sales.employees as e
	inner join cte_emp_hierarchy as ceh
		on e.managerid = ceh.employeeid
)
select
	* 
from cte_emp_hierarchy;