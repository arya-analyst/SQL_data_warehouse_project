---- Exploring and unnderstanding our datasets

-- Have a sneek peak into your dataset. Running DESCRIBE command to quickly display the structure of a table 

select * from cust_info;
select * from prd_info;
select * from sales_details;
select * from cust_dim;
select * from loc_dim;
select * from parts_category;

-- Running DESCRIBE command to quickly display the structure of a table 

DESC cust_info
INFO cust_info

-- We can already spot some data anomaly in our dataset. We'll work on it clean our dataset

---- #### cust_info #### ----

-- Checking for NULLS or Duplicates in Primary Key
-- Expectations: No Result

select cst_id, count(*)
from cust_info
group by cst_id
having count(*) > 1 or cst_id is null

-- Observation: 
-- 1. cst_key is just an extension of cst_id i.e., cst_key contains no specific details. It's just a CONACTENATION of AW000 followed by cst_id
-- 2. We have multiple NULL values (4 to be precise) and 5 cst_id having duplicate entries as well. We need to have a look at them and drop the vague ones

select from cust_info
where cst_id = 29466

delete from cust_info
where cst_id = 29466 and cst_gndr is null;

-- This is one way to have a look at your duplicate data and drop rows which are less informative in comparison

select from cust_info where cst_id is null
delete from cust_info where cst_id is null; -- Rows where cust_id was null was checked and were found to be containing no meaningful insights

-- It is not possible to check and drop each and every record one by one

SELECT c.*
FROM cust_info c
JOIN (
    SELECT cst_id
    FROM cust_info
    GROUP BY cst_id
    HAVING COUNT(*) > 1
) dup
ON c.cst_id = dup.cst_id;

-- OR

select * from cust_info
where cst_id in (SELECT cst_id
    FROM cust_info
    GROUP BY cst_id
    HAVING COUNT(*) > 1)
    
    
-- A quick glance and we can observe that generally the most recently created rows are the ones that have more data in comparison

select * from cust_info

SELECT *
FROM cust_info c
WHERE EXISTS (
    SELECT 1
    FROM (
        SELECT cst_id, cst_create_date,
               ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) rnk
        FROM cust_info
    ) sub
    WHERE sub.rnk > 1
      AND sub.cst_id = c.cst_id
      AND sub.cst_create_date = c.cst_create_date
);

DELETE FROM cust_info c
WHERE EXISTS (
    SELECT 1
    FROM (
        SELECT cst_id, cst_create_date,
               ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) rnk
        FROM cust_info
    ) sub
    WHERE sub.rnk > 1
      AND sub.cst_id = c.cst_id
      AND sub.cst_create_date = c.cst_create_date
);

select * from cust_info -- directed 4 rows deleted


-- Re-check for duplicates

select cst_id, count(*)
from cust_info
group by cst_id
having count(*) > 1 or cst_id is null

-- QUALITY CHECK: Check for unwanted spaces in string values
-- Expectations: No Results

select * from cust_info -- A rough look at the cst_firstname and cst_lastname reveals that there are too many unwanted spaces there

select cst_firstname from cust_info
where cst_firstname != trim(cst_firstname) -- If the original value isn't equal to the same value after trimming, it means there are spaces! 17 rows have spaces

select cst_lastname from cust_info
where cst_lastname != trim(cst_lastname) -- 22 rows have spaces

select cst_gndr from cust_info
where cst_gndr != trim (cst_gndr) -- No unnecessary spaces found.

select cst_marital_status from cust_info
where cst_marital_status != trim (cst_marital_status) -- No unnecessary spaces found

-- Updating columns and removing unwanted spaces

UPDATE cust_info
SET cst_firstname = TRIM(cst_firstname),
    cst_lastname = TRIM(cst_lastname);

-- QUALITY CHECK: Check the consistency of values in low cardinality columns

-- Data Standardization & Consistency

select distinct cst_gndr from cust_info; -- We have M, F and NULL. We'll use default value 'N/A' for missing values!

UPDATE cust_info
SET cst_gndr = CASE 
                  WHEN cst_gndr = 'M' THEN 'Male'
                  WHEN cst_gndr = 'F' THEN 'Female'
                  ELSE 'n/a'
               END,
    cst_marital_status = CASE
                             WHEN cst_marital_status = 'M' THEN 'Married'
                             WHEN cst_marital_status = 'S' THEN 'Single'
                             ELSE 'n/a'
                         END;
                             
select * from cust_info; -- COMMIT               


---- #### prd_info #### ----

select * from prd_info

-- Checking for NULLS or Duplicates in Primary Key
-- Expectations: No Result

select prd_id, count(*)
from prd_info
group by prd_id
having count(*) > 1 or prd_id is null -- There's no null or duplicates 

-- We need to take the first 5 characters from prod_key to make a new column so that we can join this dataset with parts_category.id

ALTER TABLE prd_info
ADD cat_id VARCHAR2(10);

UPDATE prd_info
SET cat_id = SUBSTR(prd_key, 1, 5);

select * from prd_info;
select * from parts_category;

-- Another issue is that we need to convert the '-' to '_' in recently formed cat_id to be able to connect prd_info and parts_category

update prd_info
set cat_id = replace(cat_id, '-', '_')

-- Similarly, we have to extract from the 7th character in prod_key to make a new column so that we can join this dataset with sales_details.sls_prd_key

ALTER TABLE prd_info
ADD sls_prd_key VARCHAR2(20);

UPDATE prd_info
SET sls_prd_key = SUBSTR(prd_key, 7, length(prd_key));

select * from prd_info;

-- QUALITY CHECK: Looking for vague values in prd_cost. prd_cost should not be negative or null

select * from prd_info 
where prd_cost < 0 or prd_cost is null -- We've only two rows where the prd_cost is null

select p.*, NVL2(prd_cost, prd_cost, 0) as prd_cost
from prd_info p

update prd_info
set prd_cost = NVL2(prd_cost, prd_cost, 0) -- NVL2 takes 3 expressions(It returns exp 2 if exp1 is NOT NULL. It returns exp3 if exp1 is NULL)


-- Check for invalid dates in prd_start_dt and prd_end_dt
-- the prd_end_dt needs to be converted to date format

select prd_id, prd_key, prd_start_dt, prd_end_dt,
to_date(trim(prd_end_dt), 'yyyy-mm-dd') as prd_end_dt_dummy
from prd_info

update prd_info
set prd_end_dt = to_date(prd_end_dt, 'DD-MM-YY')

DESC prd_info



-- the prd_end_dt should not be less than prd_start_dt. We've multiple entries for one prd_key which indicates the pricing history of that product
-- Now, the most logical outcome would be to partition the data based on prd_key 
-- and then use the lead() function to assign the next date of the prd_start_dt of same prd_key to prd_end_dt and substract 1 day
-- thus the next star_dt will be after thee end_dt of the previous one

with temp as (
select prd_id, prd_key, prd_start_dt, prd_end_dt,
lead(prd_start_dt) over(partition by prd_key order by prd_start_dt asc) as dummy,
lead(prd_start_dt) over(partition by prd_key order by prd_start_dt asc) - 1 as dummy2,
row_number() over(partition by prd_key order by prd_start_dt asc) as rnk
from prd_info
)
select distinct prd_key from temp where rnk > 1


MERGE INTO prd_info p
USING (
    SELECT prd_id,
           prd_key,
           prd_start_dt,
           LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC) - 1 AS new_end_dt
    FROM prd_info
) sub
ON (p.prd_id = sub.prd_id)
WHEN MATCHED THEN
    UPDATE SET p.prd_end_dt = sub.new_end_dt;

select * from prd_info;


---- #### sales_details #### ----

select * from sales_details

-- Our date columns are in number format. We need to convert them into date format

-- Firstly, we'll search for data anamalies 

select * from sales_details
where sls_order_dt <= 0  or sls_order_dt is null -- 17 rows have 0 as sls_order_dt. We'll need to cast that as null

select * from sales_details
where sls_ship_dt <= 0 or sls_ship_dt is null -- We've valid data in sls_ship_dt column

select * from sales_details
where sls_due_dt <= 0 or sls_due_dt is null -- We've valid data in sls_due_dt column

-- Updating and converting sls_order_dt to date datatype and assigning NULL value to anamalies

select sls_ord_num, sls_prd_key, sls_order_dt,
case when sls_order_dt <= 0 or length(sls_order_dt) != 8 then NULL
    else to_date(to_char(sls_order_dt), 'yyyymmdd')
end as dummy
from sales_details

update sales_details
set sls_order_dt = case when sls_order_dt <= 0 or length(sls_order_dt) != 8 then NULL
                        else to_date(to_char(sls_order_dt), 'yyyymmdd')
                   end;

-- We've failed to update and will try an alternative approach to update the sls_order_dt 

ALTER TABLE sales_details ADD sls_order_dt_new DATE;

UPDATE sales_details
SET sls_order_dt_new = CASE 
                          WHEN sls_order_dt <= 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
                          ELSE TO_DATE(TO_CHAR(sls_order_dt), 'YYYYMMDD')
                        END;
                        
-- Updating other number column into date format

ALTER TABLE sales_details ADD sls_ship_dt_new DATE;
ALTER TABLE sales_details ADD sls_due_dt_new DATE;

UPDATE sales_details
SET sls_ship_dt_new = TO_DATE(TO_CHAR(sls_ship_dt), 'YYYYMMDD'),
    sls_due_dt_new = TO_DATE(TO_CHAR(sls_due_dt), 'YYYYMMDD')

select * from sales_details


-- Check DATA CONSISTENCY: Between Sales, Qyantity and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative    

select sls_sales, sls_quantity, sls_price
from sales_details 
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0

-- Now we'll look for ways to fix this

select sls_sales, sls_quantity, sls_price,
case when sls_sales != sls_quantity * abs(sls_price) or sls_sales is null or sls_sales <= 0
     then sls_quantity * abs(sls_price)
     else sls_sales
end as sls_sales_dummy,
case when sls_price is null or sls_price <= 0
     then sls_sales / sls_quantity
     else sls_price
end as sls_price_dummy
from sales_details 
where sls_sales != sls_quantity * sls_price
or sls_price != sls_sales / sls_quantity
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0

-- Updating the required rows

update sales_details
set sls_sales = case when sls_sales != sls_quantity * abs(sls_price) or sls_sales is null or sls_sales <= 0
                     then sls_quantity * abs(sls_price)
                     else sls_sales
                end,
    sls_price = case when sls_price is null or sls_price <= 0
                     then sls_sales / sls_quantity
                     else sls_price
                end

-- Check: 
-- Expectation : No Result 

select sls_sales, sls_quantity, sls_price
from sales_details 
where sls_sales != sls_quantity * sls_price
or sls_price != sls_sales / sls_quantity
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0


---- #### cust_dim #### ----

select * from cust_dim


-- Checking for NULLS or Duplicates in Primary Key
-- Expectations: No Result

select cid, count(*)
from cust_dim
group by cid
having count(*) > 1 or cid is null -- There's no null or duplicates 

-- Now we can notice that in cust_dim.cid the id has been stored in two types.
-- >> First one is NASAW%
-- >> Second one is AW%
-- We can remove the additional NAS from the required id so that we can join cust_dim.cid with cust_info.cst_key
-- We're removing NAS as all the records in cust_info.cst_key have records in AW% format


select cid, bdate, gen,
case when cid like 'NAS%' then substr(cid, 4, length(cid))
     else cid
end as cid_dummy
from cust_dim


update cust_dim
set cid = case when cid like 'NAS%' then substr(cid, 4, length(cid))
               else cid
          end


-- Data Standardization & Consistency 

select gen, count(*)
from cust_dim
group by gen

update cust_dim
set gen = case when upper(trim(gen)) = 'M' then 'Male'
               when upper(trim(gen)) = 'F' then 'Female'
               when trim(gen) = 'Male' then 'Male'
               when trim(gen) = 'Female' then 'Female'
               else 'n/a'
          end



-- Identify out-of-range dates


ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY';

select max(bdate), min(bdate)
from cust_dim -- we've unusual data anamoly in our bdate colummn

select * 
from cust_dim
where bdate > trunc(sysdate) -- We've 16 rows where the DOB is greater than today's date. This needs to be flagged and reported



---- #### cust_dim #### ----


select * from loc_dim


-- Checking for NULLS or Duplicates in Primary Key
-- Expectations: No Result

select cid, count(*)
from loc_dim
group by cid
having count(*) > 1 or cid is null -- There's no NULL or Duplicate values


-- We need to remove '-' from the cis so that we can join it with other tables


update loc_dim
set cid = replace(cid, '-', '')


-- QUALITY CHECK: Checking for anamalies in cntry column


select cntry, count(*)
from loc_dim
group by cntry


update loc_dim
set cntry = case when trim(cntry) = 'DE' then 'Germany'
     when trim(cntry) in ('US', 'USA') then 'United States'
     when trim(cntry) = '' or cntry is null then 'n/a'
     else trim(cntry) 
end


select cntry, count(*)
from loc_dim
group by cntry -- check




---- #### parts_category #### ----

select * from parts_category



-- Checking for NULLS or Duplicates in Primary Key
-- Expectations: No Result

select id, count(*)
from parts_category
group by id
having count(*) > 1 or id is null -- there's no NULL or Duplicates



-- QUALITY CHECK: Checking for unwanted spaces and data anamalies


select cat, count(*)
from parts_category
group by cat

select maintenance, count(*)
from parts_category
group by maintenance

select subcat, count(*)
from parts_category
group by subcat



-- The data has now been cleaned and is ready to be JOINed and used for gaining business insights



----- >> Now, we'll create dimensions so that we can write queries in simple manner to get meaningful insights


select 
    cst.cst_id as customer_id,
    cst.cst_key as customer_key,
    cst.cst_firstname as first_name,
    cst.cst_lastname as last_name,
    cst.cst_marital_status as marital_status,
    cst.cst_gndr as gender,
    cst.cst_create_date as create_date,
    cstdm.cid as cid,
    cstdm.bdate as birth_date,
    cstdm.gen as gen,
    cstlc.cid as dummy,
    cstlc.cntry as country 
from cust_info cst
left join cust_dim cstdm on cst.cst_key = cstdm.cid
left join loc_dim cstlc on cst.cst_key = cstlc.cid


-- DATA INTEGRITY: Checking whether the gender column in cust_info and cust_dim have matching record or not



select distinct 
    cst.cst_gndr as gender,
    cstdm.gen as gen
from cust_info cst
left join cust_dim cstdm on cst.cst_key = cstdm.cid
left join loc_dim cstlc on cst.cst_key = cstlc.cid
order by 1, 2 



-- We've records with wrong mapping of genders in our table. We've records which are marked M in one table and F in other and vice versa
-- In this scenario, it'd be appropriate to consult the Business Unit ergarding which table is the MDG file and act accordingly
-- We'll suppose that the cust_info is the master data file here



select distinct 
    cst.cst_gndr as gender,
    cstdm.gen as gen,
    case when cst.cst_gndr != 'n/a' then cst.cst_gndr
         else coalesce(cstdm.gen, 'n/a') -- coalesce returns the first NON-NULL value
    end as new_gen
from cust_info cst
left join cust_dim cstdm on cst.cst_key = cstdm.cid
left join loc_dim cstlc on cst.cst_key = cstlc.cid
order by 1, 2 



---- >> Creating CUSTOMER dimension by joining cust_info, cust_dim and loc_dim tables


create view dim_customer as (
    select 
        cst.cst_id as customer_id,
        cst.cst_key as customer_key,
        cst.cst_firstname as first_name,
        cst.cst_lastname as last_name,
        cst.cst_marital_status as marital_status,
        case when cst.cst_gndr != 'n/a' then cst.cst_gndr
             else coalesce(cstdm.gen, 'n/a') -- coalesce returns the first NON-NULL value
        end as gender,
        cst.cst_create_date as create_date,
        cstdm.bdate as birthdate,
        cstlc.cntry as country 
    from cust_info cst
    left join cust_dim cstdm on cst.cst_key = cstdm.cid
    left join loc_dim cstlc on cst.cst_key = cstlc.cid
)


select * from dim_customer;




---- >> Creating PRODUCT dimension table by joining prd_info and parts_category tables

create view dim_product as(
    select 
        prd.prd_id as prd_id,
        prd.prd_key as prd_key,
        prd.cat_id as cat_id,
        prd.sls_prd_key as prd_sls_key,
        prd.prd_nm as prd_name,
        prc.cat as category,
        prc.subcat as subcategory,
        prd.prd_cost as prd_cost,
        prd.prd_line as prd_line,
        prd.prd_start_dt as prd_start_date,
        prd.prd_end_dt as prd_end_date,
        prc.maintenance as maintenance  
    from prd_info prd
    left join parts_category prc on prd.cat_id = prc.id
    where prd_end_dt is null -- Filter out all historical data. Products have records of it's historical pricing at different point of time
)

select * from dim_product




---- >> The sales_details table will act as the main table and can be used to query to get the required output


select * from sales_details



