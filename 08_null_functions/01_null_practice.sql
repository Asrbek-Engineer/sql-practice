-- NULL practice: IS NULL, COALESCE, ISNULL, NULLIF
-- Database: SalesDB
USE SalesDB;

/* ============ Part 1: Finding NULLs (~8 min) ============ */

-- Task 1: Show customers who have no score.
select
	customerid,
	score
from sales.customers
where score is null;

-- Task 2: Show customers who do have a score.
select
	customerid,
	score
from sales.customers
where score is not null;

-- Task 3: Show employees who have no manager (sales.Employees).
select
	employeeid,
	managerid
from sales.employees
where managerid is null;

/* ============ Part 2: Replacing NULLs (~15 min) ============ */

-- Task 4: Show each customer's full name (firstname + ' ' + lastname).
-- First try it with the + operator, then fix it so a missing lastname does not turn the whole name into NULL.
select
	customerid,
	firstname,
	lastname,
	firstname + ' ' + lastname as fullname,
	trim(isnull(firstname, '') + ' ' + isnull(lastname, '')) as fixed_fullname
from sales.customers;

-- Task 5: Show each customer's score plus a 10-point bonus. A missing score counts as 0.
select
	customerid,
	isnull(score, 0) + 10 as changed_score
from sales.customers;

-- Task 6: For each order, show a contact address:
-- use billaddress; if it is missing use shipaddress; if both are missing show 'Unknown'.
select
	orderid,
	coalesce(billaddress, shipaddress, 'Unknown') as contact_address
from sales.orders;

-- Task 7 (answer as a comment): Can you write Task 6 with ISNULL in a single call? Why or why not?
-- No, because isnull() gets only two parameters

/* ============ Part 3: NULLs in aggregation (~10 min) ============ */

-- Task 8: Show three numbers for customers:
-- COUNT(*), COUNT(score) and AVG(score).
-- Comment: why are the two counts different?
select
	count(*) as count_score_row,
	count(score) as count_score_exist,
	avg(score) as average_score
from sales.customers;
-- count(*) counts all rows; count(score) counts only non-null values

-- Task 9: Show AVG(score) and the average when a missing score counts as 0.
-- Comment: which one is correct for a report, and why?
select
	avg(score) as avg_known_scores,
	avg(isnull(score, 0)) as avg_null_as_zero
from sales.customers;
-- AVG(score) is usually correct: NULL means "unknown", not 0.
-- Treating NULL as 0 pulls the average down artificially.

/* ============ Part 4: NULLIF and sorting (~10 min) ============ */

-- Task 10: Show orderid, sales, quantity and price per unit.
-- Protect the query from division by zero using NULLIF (no WHERE filter this time).
select
	orderid,
	sales,
	quantity,
	cast(sales as decimal(10,2)) / nullif(quantity, 0) as price
from sales.orders;

-- Task 11: Show customers sorted by score from lowest to highest,
-- but put customers without a score at the end. Use COALESCE in ORDER BY.
select
	score
from sales.customers
order by coalesce(score, (select max(score) from sales.customers) + 1);

/* ============ Part 5: NULL vs empty vs blank (~10 min) ============ */

-- Task 12: Build a small list with UNION ALL containing:
-- NULL, '' (empty), '   ' (blank), 'A'.
-- For each value show: the value, DATALENGTH(value), and whether it IS NULL (1/0 is not needed, just filter in a second query).
-- 1
select
	data.value,
	datalength(data.value) as value_length
from
(
	select null as value
	union all
	select '' 
	union all
	select ' ' 
	union all
	select 'A'
) as data;

-- 2
select
	data.value
from
(
	select null as value
	union all
	select '' 
	union all
	select ' ' 
	union all
	select 'A'
) as data
where data.value is null;
-- Task 13: Clean the same list so that empty and blank values become NULL.
-- Hint: NULLIF + TRIM.
select
	nullif(trim(data.value), '') as list
from
(
	select null as value
	union all
	select '' 
	union all
	select ' ' 
	union all
	select 'A'
) as data;

/* ============ Bonus ============ */

-- Bonus (answer as a comment): Why does WHERE score = NULL return no rows,
-- while WHERE score IS NULL works?
-- Comparing with NULL returns UNKNOWN, not TRUE. WHERE keeps only TRUE rows. IS NULL checks for NULL directly.