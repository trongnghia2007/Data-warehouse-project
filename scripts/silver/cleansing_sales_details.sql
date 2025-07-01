use DataWarehouse

-- Check whether cst_id and prd_key can be used
select *
from bronze.crm_sales_details
where sls_cust_id not in (select cst_id from silver.crm_cust_info)
---------------------------------------------------------------------------

-- Check for invalid dates
select sls_order_dt
from bronze.crm_sales_details
where len(sls_order_dt) != 8 or sls_order_dt <= 0  -- do the same with ship and due dt

select *
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt
---------------------------------------------------------------------------

-- Check for invaid sales, quantity and price
-- >> sales = quantity * price
-- >> values must not be null or <= 0 
select 
	sls_sales,
	sls_quantity,
	sls_price
from bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price
	or sls_sales is null or sls_quantity is null or sls_price is null
	or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
order by sls_sales, sls_quantity, sls_price
---------------------------------------------------------------------------

-- Data standardization and then load data
insert into silver.crm_sales_details (
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)

select
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	case when len(sls_order_dt) != 8 or sls_order_dt <= 0 then Null
		 else cast(cast(sls_order_dt as varchar) as date)
	end sls_order_dt,

	case when len(sls_ship_dt) != 8 or sls_ship_dt <= 0 then Null
		 else cast(cast(sls_ship_dt as varchar) as date)
	end sls_ship_dt,

	case when len(sls_due_dt) != 8 or sls_due_dt <= 0 then Null
		 else cast(cast(sls_due_dt as varchar) as date)
	end sls_due_dt,

	case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
		 then sls_quantity * abs(sls_price)
		 else sls_sales
	end sls_sales,

	sls_quantity,

	case when sls_price is null or sls_price <= 0
		 then sls_sales / nullif(sls_quantity, 0)
		 else sls_price
	end sls_price
from bronze.crm_sales_details
