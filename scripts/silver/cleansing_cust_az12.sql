use DataWarehouse

-- Check the cid can connect to cst_key in silver.crm_cust_info
select 
	cid,
	case when cid like 'NAS%' then substring(cid, 4, len(cid))
		 else cid
	end cid,
	bdate,
	gen
from bronze.erp_cust_az12
where case when cid like 'NAS%' then substring(cid, 4, len(cid))
		   else cid
	  end not in (select distinct cst_key from silver.crm_cust_info)
---------------------------------------------------------------------------

-- Check for invalid birthdate (in the future)
select distinct bdate
from bronze.erp_cust_az12
where bdate > getdate() 
--------------------------------------------------

-- Check for invalid gender
select distinct gen
from bronze.erp_cust_az12
--------------------------------------------------

-- Data standardization and then load data
insert into silver.erp_cust_az12 (
	cid,
	bdate,
	gen
)
select 
	case when cid like 'NAS%' then substring(cid, 4, len(cid))
		 else cid
	end cid,

	case when bdate > getdate() then null
		 else bdate
	end bdate,

	case when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
		 when upper(trim(gen)) in ('M', 'MALE') then 'Male'
		 else 'n/a'
	end gen
from bronze.erp_cust_az12
