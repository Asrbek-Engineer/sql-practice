/* Partitions */
use SalesDB;
go

-- partitioning = splitting one big table into smaller physical parts (partitions) by a column (usually a date),
-- while it still looks like ONE table to queries.
-- chain:  partition function (rules)  ->  filegroups + .ndf files (storage)
--         ->  partition scheme (rule -> filegroup mapping)  ->  partitioned table

-- step 1: create partition function
-- RANGE LEFT: each boundary value belongs to the LEFT partition
--   p1: <= 2023-12-31 | p2: 2024 | p3: 2025 | p4: > 2025-12-31
create partition function partition_by_date (date)
as range left for values ('2023-12-31', '2024-12-31', '2025-12-31');
go

select
	name,
	function_id,
	type,
	type_desc,
	boundary_value_on_right
from sys.partition_functions;

-- step 2: create filegroups (one per partition: 3 boundaries -> 4 partitions)
alter database salesdb add filegroup fg_2023;
alter database salesdb add filegroup fg_2024;
alter database salesdb add filegroup fg_2025;
alter database salesdb add filegroup fg_2026;
go

-- to remove a filegroup, e.g. fg_2023 (only works while it has no files):
-- alter database salesdb remove filegroup fg_2023;

-- query lists all existing filegroups
select
	*
from sys.filegroups
where type = 'FG';

-- step 3: add .ndf files to each filegroup
alter database salesdb add file
(
	name = p_2023, -- logical name
	filename = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\P_2023.ndf'
) to filegroup fg_2023;

alter database salesdb add file
(
	name = p_2024,
	filename = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\P_2024.ndf'
) to filegroup fg_2024;

alter database salesdb add file
(
	name = p_2025,
	filename = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\P_2025.ndf'
) to filegroup fg_2025;

alter database salesdb add file
(
	name = p_2026,
	filename = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\P_2026.ndf'
) to filegroup fg_2026;
go

select
	fg.name as file_group_name,
	mf.name as logical_file_name,
	mf.physical_name as physical_file_path,
	mf.size / 128 as size_in_mb
from sys.filegroups as fg
join sys.master_files as mf
	on fg.data_space_id = mf.data_space_id
where mf.database_id = db_id('salesdb');

-- step 4: create partition scheme (maps each partition to a filegroup, in order)
create partition scheme scheme_partition_by_date
as partition partition_by_date
to (fg_2023, fg_2024, fg_2025, fg_2026);
go

-- query lists all partition schemes
select
	ps.name as partition_scheme_name,
	pf.name as partition_function_name,
	ds.destination_id as partition_number,
	fg.name as file_group_name
from sys.partition_schemes as ps
join sys.partition_functions as pf
	on ps.function_id = pf.function_id
join sys.destination_data_spaces as ds
	on ps.data_space_id = ds.partition_scheme_id
join sys.filegroups as fg
	on ds.data_space_id = fg.data_space_id;

-- step 5: create partitioned table
create table sales.orders_partitioned
(
	orderid int,
	orderdate date,
	sales int
) on scheme_partition_by_date (orderdate);
go

-- step 6: insert data into the partitioned table
insert into sales.orders_partitioned values (1, '2023-05-15', 100);
insert into sales.orders_partitioned values (2, '2024-07-22', 100);
insert into sales.orders_partitioned values (3, '2025-12-31', 20);   -- boundary value -> goes to the 2025 partition (RANGE LEFT)
insert into sales.orders_partitioned values (4, '2026-10-20', 160);

select * from sales.orders_partitioned;

-- check: how many rows are in each partition
select
	p.partition_number as partition_number,
	f.name as partition_file_group,
	p.rows as number_of_rows
from sys.partitions as p
join sys.destination_data_spaces as dds
	on p.partition_number = dds.destination_id
join sys.filegroups as f
	on dds.data_space_id = f.data_space_id
where object_name(p.object_id) = 'orders_partitioned';

-- step 7: performance - compare with a normal (not partitioned) copy
drop table if exists sales.orders_no_partition;
select * into sales.orders_no_partition from sales.orders_partitioned;

select * from sales.orders_no_partition
where orderdate = '2026-10-20';   -- execution plan: number of rows read = 4 (whole table)

select * from sales.orders_partitioned
where orderdate = '2026-10-20';   -- execution plan: number of rows read = 1 (partition elimination)
go

/* ============ Cleanup (run only if you want to remove everything) ============ */
-- order matters: table -> scheme -> function -> files -> filegroups
-- drop table if exists sales.orders_partitioned;
-- drop table if exists sales.orders_no_partition;
-- drop partition scheme scheme_partition_by_date;
-- drop partition function partition_by_date;
-- alter database salesdb remove file p_2023;  -- repeat for p_2024, p_2025, p_2026
-- alter database salesdb remove filegroup fg_2023;  -- repeat for fg_2024, fg_2025, fg_2026