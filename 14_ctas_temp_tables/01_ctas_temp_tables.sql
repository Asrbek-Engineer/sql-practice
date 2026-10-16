/* ctas - create table as select */
use SalesDB;
go

-- rule: SELECT ... INTO creates a NEW physical table and copies the data (a snapshot)
-- rule: the data does NOT update by itself; to refresh it, drop and create it again
-- rule: SELECT ... INTO fails if the table already exists -> drop it first (re-runnable script)
-- note: datename(month, ...) groups by month NAME (text): two years would merge
--       and the months sort alphabetically -> prefer datetrunc(month, orderdate)
if object_id('sales.monthly_orders', 'U') is not null
	drop table sales.monthly_orders;
go

select
	datename(month, orderdate) as order_month,
	count(orderid) as total_orders
into sales.monthly_orders
from sales.orders
group by datename(month, orderdate);

select * from sales.monthly_orders;

/* temporary tables */
-- rule: #table lives in tempdb and disappears when the session (connection) ends
-- rule: use it for intermediate steps (staging) that you change before saving the final result

select
	*
into #orders
from sales.orders;

delete from #orders
where orderstatus = 'Delivered';

-- save the final result as a permanent table (drop first so the script can run again)
if object_id('sales.orders_test', 'U') is not null
	drop table sales.orders_test;
go

select
	*
into sales.orders_test
from #orders;

select * from sales.orders_test;