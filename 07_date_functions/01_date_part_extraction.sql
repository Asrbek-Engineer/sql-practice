/*
	DATE & TIME (TIMESTAMP(ORACLE, POSTGRES, MYSQL), DATETIME2(SQL SERVER))
*/
select
	orderid,
	orderdate,
	shipdate,
	creationtime
from sales.Orders;

/*
	Part Extraction:
		Year() - returns the year from date
		Month() - returns the month from date
		Day() - returns the day from date
*/
select
	orderid,
	creationtime,
	year(creationtime) as year,
	month(creationtime) as month,
	day(creationtime) as day
from sales.Orders;

/*
	Part Extraction:
		Datepart() - returns a specific part of a date as a number
		syntax: datepart(part, date)
		example: datepart(month, orderdate)
		abbreviation of part: datepart(mm, '2026-09-29')
		international standard week: datepart(iso_week, ...)
*/
select
	orderid,
	creationtime,
	datepart(year, creationtime) as year_dp,
	datepart(month, creationtime) as month_dp,
	datepart(day, creationtime) as day_dp,
	datepart(hour, creationtime) as hour_dp,
	datepart(quarter, creationtime) as quarter_dp,
	datepart(week, creationtime) as week_dp
from sales.Orders;

/*
	Part Extraction:
		Datename(part, date) - returns string value
*/
select
	orderid,
	creationtime,
	datename(month, creationtime) as month_dn,
	datename(weekday, creationtime) as week_dn,
	datename(day, creationtime) as day_dn,
	datename(year, creationtime) as year_dn
from sales.Orders;

/*
	Part Extraction:
		Datetrunc() - truncates the date to the specific part
		*Date part resets to 01 / Time part resets to 00
		syntax: datetrunc(part, date)
*/
select
	orderid,
	creationtime,
	datetrunc(minute, CreationTime) as minute_dt,
	datetrunc(day, CreationTime) as day_dt,
	datetrunc(year, CreationTime) as year_dt
from sales.Orders;

select
	datetrunc(month, creationtime) as creation,
	count(*) as count
from sales.Orders
group by datetrunc(month, creationtime);

/*
	Part Extraction:
		Eomonth() - returns the last day of month
*/
select
	eomonth(creationtime) as end_of_month,
	datetrunc(month, creationtime) as start_of_month
from sales.Orders;

/*
	Comparing Extract Functions:   Return type
		Day, Month, Year, Datepart -> Int
		Datename				   -> String
		Datetrunc				   -> Datetime
		Eomonth					   -> Date

*/

/*
  Use Cases – Date Extraction
*/
-- How many orders were placed each year
select
	year(orderdate) as year,
	count(*) nr_of_orders
	from sales.orders
group by year(orderdate);

-- How many orders were placed each month
select
	month(orderdate) as month,
	datename(month, orderdate) as name_of_month,
	count(*) nr_of_orders
	from sales.orders
group by month(orderdate), datename(month, orderdate);

/*
	Date Filtering
*/
-- Show all orders that were placed during the month of February
select
	*
from sales.orders
Where month(orderdate) = 2;