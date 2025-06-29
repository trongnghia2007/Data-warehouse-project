-- Check for duplicate or null in Primary key. Expectation result: no
select 
	cst_id,
	COUNT(*)
from bronze.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null
----------------------------------------------------------------------

-- Select the latest info of the customer
select *
from bronze.crm_cust_info
where cst_id = 29466


select 
*,
ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info
where cst_id = 29466


select * 
from (	
	select 
	*,
	ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
	from bronze.crm_cust_info
)t
where cst_id = 29466 and flag_last = 1
------------------------------------------------------------------------------------

-- Check for unwanted spaces. Expectation result: No
select cst_firstname
from bronze.crm_cust_info
where cst_firstname != trim(cst_firstname)


select
	cst_id,
	cst_key,
	trim(cst_firstname) as cst_firstname,
	trim(cst_lastname) as cst_lastname,
	cst_create_date,
	cst_gndr,
	cst_create_date
from (	
	select 
	*,
	ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
	from bronze.crm_cust_info
	
)t
where cst_id is not null and flag_last = 1
------------------------------------------------------------------------------------

-- Data standardization & then Load data 
insert into silver.crm_cust_info (      
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date)

select
	cst_id,
	cst_key,
	trim(cst_firstname) as cst_firstname,
	trim(cst_lastname) as cst_lastname,

	case when upper(trim(cst_marital_status)) = 'S' then 'Single'
		 when upper(trim(cst_marital_status)) = 'M' then 'Married'
		 else 'n/a'
	end cst_marital_status,

	case when upper(trim(cst_gndr)) = 'F' then 'Female'
		 when upper(trim(cst_gndr)) = 'M' then 'Male'
		 else 'n/a'
	end cst_gndr,
	cst_create_date
from (	
	select 
	*,
	ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
	from bronze.crm_cust_info
	
)t
where cst_id is not null and flag_last = 1

