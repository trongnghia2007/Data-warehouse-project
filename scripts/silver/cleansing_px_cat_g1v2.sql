-- Check for unwanted spaces
select * from bronze.erp_px_cat_g1v2
where cat != trim(cat) or subcat != trim(subcat) or maintenance != trim(maintenance)
------------------------------------------------------------------------------------

-- Data standardization and then load data
insert into silver.erp_px_cat_g1v2 (
	id,
	cat,
	subcat,
	maintenance
)
select 
	id,
	cat,
	subcat,
	maintenance
from bronze.erp_px_cat_g1v2
