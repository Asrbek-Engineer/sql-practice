/* Experiment: heap vs rowstore vs columnstore storage (AdventureWorksDW) */
use AdventureWorksDW2025;
go

-- heap (no index)
drop table if exists factinternetsales_hp;
select *
into factinternetsales_hp      -- data space: 9.633 mb, index space: 0.008 mb
from FactInternetSales;
go

-- rowstore (clustered index)
drop table if exists factinternetsales_rs;
select *
into factinternetsales_rs
from FactInternetSales;
go
create clustered index idx_factinternetsales_rs
	on factinternetsales_rs (salesordernumber, salesorderlinenumber);  -- data space: 9.633 mb, index space: 0.055 mb
go

-- columnstore (clustered columnstore index)
drop table if exists factinternetsales_cs;
select *
into factinternetsales_cs
from FactInternetSales;
go
create clustered columnstore index idx_factinternetsales_cs
	on factinternetsales_cs;                                           -- data space: 1.461 mb, index space: 0.000 mb
go

/*
	Result:
	heap        9.633 mb
	rowstore    9.633 mb + 0.055 mb index
	columnstore 1.461 mb  -> about 85% smaller (about 6.6x compression)

	Why: columnstore stores each COLUMN separately; values in one column are similar,
	so they compress very well. Queries read only the columns they need.
	Use columnstore for big analytical (DWH / fact) tables: aggregations over many rows.
	Use rowstore for OLTP: reading or changing single rows (seek by key).
*/

-- missing indexes: run a query, then ask SQL Server what index would have helped
select
	fs.salesordernumber,
	dp.englishproductname,
	dp.color
from FactInternetSales as fs
inner join DimProduct as dp
	on fs.productkey = dp.productkey
where dp.color = 'Black'
	and fs.orderdatekey between 20101229 and 20101231;

select * from sys.dm_db_missing_index_details;
-- note: these are only suggestions; check them before creating, too many indexes slow down INSERT / UPDATE
go

/* Cleanup */
drop table if exists factinternetsales_hp;
drop table if exists factinternetsales_rs;
drop table if exists factinternetsales_cs;
go