use SalesDB;
go

/* Index */
-- create ctas table
select
	*
into sales.db_customers
from sales.customers;

select * from sales.db_customers;
go

-- create index to ctas table (sales.db_customers)
create clustered index idx_db_customers_customerid on sales.db_customers (customerid);
go

-- drop index
drop index idx_db_customers_customerid on sales.db_customers;
go

-- searching with lastname
select
	*
from sales.db_customers
where lastname = 'Brown';
go

-- to improve performance create nonclustered index for non-unique values
create nonclustered index idx_db_customers_lastname on sales.db_customers (lastname);
go

-- nonclustered index for firstname (NONCLUSTERED is the default)
create index idx_db_customers_firstname on sales.db_customers (firstname);
go

/* Composite index */
create index idx_db_customers_country_score on sales.db_customers (country, score);
go
-- IMPORTANT
/*
	Leftmost prefix rule
	index columns: a, b, c, d

	Index can SEEK on:
	a
	a, b
	a, b, c

	Index CANNOT seek:
	b          -> the first column is missing

	Index is used only PARTLY (seek on the leftmost part, the rest is filtered afterwards):
	a, c       -> seek on a, then c is checked row by row
	a, b, d    -> seek on a, b, then d is checked row by row

	The order of conditions in WHERE does not matter, only which columns are present.
*/
-- so examples
select
	*
from sales.db_customers
where country = 'USA' and score > 500; -- index will be used

select
	*
from sales.db_customers
where country = 'USA'; -- index will be used

select
	*
from sales.db_customers
where score > 500 and country = 'USA'; -- index will be used (order in WHERE does not matter)

select
	*
from sales.db_customers
where score > 500; -- index won't be used for a seek (country is missing)
go

/* Rowstore & Columnstore index */
-- by default an index is rowstore
drop index idx_db_customers_customerid on sales.db_customers;
go

create clustered columnstore index idx_db_customers_cs on sales.db_customers;
go

create nonclustered index idx_db_customers_cs_firstname on sales.db_customers (firstname);
go

-- unique index - does not allow duplicate values
create unique index idx_products_product on sales.products (product);
go

-- filtered index: not allowed on clustered and columnstore indexes
select
	*
into sales.the_customers
from sales.customers;
go

create nonclustered index idx_the_customers_country on sales.the_customers (country)
where country = 'USA';
go

-- list all indexes on a specific table
exec sp_helpindex 'sales.db_customers';
go

/* ============ Monitoring ============ */

-- monitoring index usage
select
	tbl.name as table_name,
	idx.name as index_name,
	idx.type_desc as index_type,
	idx.is_primary_key,
	idx.is_unique,
	idx.is_disabled,
	s.user_seeks,
	s.user_scans,
	s.user_lookups,
	s.user_updates,
	coalesce(s.last_user_seek, s.last_user_scan) as last_used   -- the last time the index was read
from sys.indexes as idx
join sys.tables as tbl
	on tbl.object_id = idx.object_id
left join sys.dm_db_index_usage_stats as s
	on s.object_id = idx.object_id
	and s.index_id = idx.index_id
order by tbl.name, idx.name;

-- monitoring missing indexes (suggestions from SQL Server)
select * from sys.dm_db_missing_index_details;

-- monitoring duplicate indexes
-- fixed joins: each table joins on ITS OWN keys (ic -> idx, col -> ic)
select
	tbl.name as table_name,
	col.name as index_column,
	idx.name as index_name,
	idx.type_desc as index_type,
	count(*) over(partition by tbl.name, col.name) as column_count
from sys.indexes as idx
join sys.tables as tbl
	on tbl.object_id = idx.object_id
join sys.index_columns as ic
	on ic.object_id = idx.object_id
	and ic.index_id = idx.index_id
join sys.columns as col
	on col.object_id = ic.object_id
	and col.column_id = ic.column_id
order by column_count desc;

-- monitoring statistics
-- statistics = what SQL Server knows about how the data in a column is distributed;
-- the optimizer uses them to choose the plan. Old statistics -> bad plans.
-- cross apply: runs the function on the right for every row on the left (like a join to a function)
select
	schema_name(tbl.schema_id) as schema_name,
	tbl.name as table_name,
	st.name as statistic_name,
	sp.last_updated,
	datediff(day, sp.last_updated, getdate()) as days_since_last_update,
	sp.rows,
	sp.modification_counter                     -- rows changed since the last update
from sys.stats as st
join sys.tables as tbl
	on tbl.object_id = st.object_id
cross apply sys.dm_db_stats_properties(st.object_id, st.stats_id) as sp
order by sp.modification_counter desc;
go

-- update statistics
update statistics sales.db_customers;   -- all statistics of one table
go
exec sp_updatestats;                     -- all statistics of the whole database
go

-- monitoring fragmentation
-- fragmentation = the logical order of the index pages no longer matches the physical order
--                 (after many INSERT / UPDATE / DELETE), so reading becomes slower
select
	tbl.name as table_name,
	idx.name as index_name,
	s.avg_fragmentation_in_percent,
	s.page_count
from sys.dm_db_index_physical_stats(db_id(), null, null, null, 'LIMITED') as s
join sys.tables as tbl
	on tbl.object_id = s.object_id
join sys.indexes as idx
	on idx.object_id = s.object_id
	and idx.index_id = s.index_id
order by s.avg_fragmentation_in_percent desc;
go

-- rules:
--   below 10%   -> do nothing
--   10% - 30%   -> REORGANIZE (light, online, defragments the leaf pages)
--   above 30%   -> REBUILD    (heavy, recreates the whole index)
-- note: on small tables (few pages) the percentage is meaningless, look at page_count too
alter index idx_db_customers_firstname on sales.db_customers reorganize;
go
alter index idx_db_customers_firstname on sales.db_customers rebuild;
go

/* ============ Cleanup ============ */
drop index if exists idx_products_product on sales.products;
drop table if exists sales.db_customers;
drop table if exists sales.the_customers;
go