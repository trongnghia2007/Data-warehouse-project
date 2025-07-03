-- Data standardization and then load data
insert into silver.erp_loc_a101 (cid, cntry)
select
	replace(cid, '-', '') cid,
	case when trim(cntry) = 'DE' then 'Germany'
		 when trim(cntry) in ('US', 'USA') then 'United States'
		 when trim(cntry) = '' or cntry is null then 'n/a'
	     else cntry
	end cntry
from bronze.erp_loc_a101
