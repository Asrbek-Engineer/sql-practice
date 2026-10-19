use AdventureWorksDW2025;
-- execution plan in table
select
	*
from factinternetsales_hp
order by salesordernumber; -- have much cpu cost and subtree cost

-- execution plan for specific data
select
	*
from factinternetsales_hp
where carriertrackingnumber = '4911-403C-98'; -- rows read: 60398

-- execution plan when join tables + columnstore index
create clustered columnstore index idx_factinternetsales_hp_cs on factinternetsales_hp;
go

select
	p.englishproductname as product_name,
	sum(s.salesamount) as total_sales
from factinternetsales_hp as s
join dimproduct as p
	on p.productkey = s.productkey
group by p.englishproductname

-- execution plan in clustered index
select
	*
from factinternetsales
order by salesordernumber; -- have less cpu cost and subtree cost

-- execution plan for specific data in nonclustered index
create nonclustered index idx_factinternetsales_cta on factinternetsales (carriertrackingnumber);
go

select
	*
from factinternetsales
where carriertrackingnumber = '4911-403C-98'; -- rows read

-- execution plan when join tables
select
	p.englishproductname as product_name,
	sum(s.salesamount) as total_sales
from factinternetsales as s
join dimproduct as p
	on p.productkey = s.productkey
group by p.englishproductname
