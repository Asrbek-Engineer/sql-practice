select
	orderid,
	creationtime,
	format(creationtime, 'MM-dd-yyyy') as usa_format,
	format(creationtime, 'dd-MM-yyyy') as euro_format,
	format(creationtime, 'dd') as dd,
	format(creationtime, 'ddd') as ddd,
	format(creationtime, 'dddd') as dddd,
	format(creationtime, 'MM') as MM,
	format(creationtime, 'MMM') as MMM,
	format(creationtime, 'MMMM') as MMMM,
	format(creationtime, 'yy') as yy,
	format(creationtime, 'yyy') as yyy,
	format(creationtime, 'yyyy') as yyyy
from sales.orders;

-- show creationtime using the following format: day wed jan q1 2026 07:11:59 pm
select
	orderid,
	creationtime,
	'day '+ format(creationtime, 'ddd MMM') + ' ' +
	'Q' + datename(quarter, creationtime) + ' ' +
	format(creationtime, 'yyyy hh:mm:ss tt') as custom_format
from sales.orders;

-- Date Aggregations
select
	format(orderdate, 'MMM yy') as order_month,
	count(*) as nr_of_orders
from sales.orders
group by format(orderdate, 'MMM yy'), datetrunc(month, orderdate)
order by datetrunc(month, orderdate);