Create schema tech_electro; 
use tech_electro;

-- Data Exploration 
select * from External_factors limit 10;
select * from sales_data  limit 10;
select * from product_information limit 10;

-- about the data
show columns from sales_data;
describe external_factors;


-- Data cleaning 
-- Data type cleaning - 'Sales Date' to Date, 'GDP' to Decimal, 'Inflation Rate' to Decimal, 'Seasonal factor' to Decimal
alter table external_factors
add column New_sales_date date;
set sql_safe_updates = 0; -- putting off safe updates;
Update external_factors
set New_sales_date = str_to_date(Sales_Date,'%d/%m/%Y');
alter table external_factors
Drop column sales_date;
alter table external_factors
change column New_sales_date Sales_date date;
alter table external_factors
modify column GDP decimal(15,2),
modify column inflation_rate decimal(15,2),
modify column seasonal_factor decimal (5,2);
show columns from external_factors;

-- Product table cleaning 
-- product_id not null, product_category text, promotions enum('yes' 'no')
alter table product_information 
Rename to product_data;
alter table product_data 
add column New_promotions enum('yes','no');
update product_data
set new_promotions = case
when promotions ='yes' then 'yes'
when promotions='no' then 'no'
else null
end;
alter table product_data
drop promotions;
alter table product_data
change column new_promotions promotions enum('yes', 'no');
alter table product_data
modify column product_id int not null;

-- sales_data
-- product_id int not null, sales_date date, inventory_quantity int, product_cost decimal(10,2)
alter table sales_data
add column new_sales_date date;
update sales_data
set new_sales_date = str_to_date(sales_date, '%d/%m/%Y');
alter table sales_data
drop sales_date;
alter table sales_data
Change column new_sales_date sales_date date;
alter table sales_data
modify product_cost decimal(10,2),
modify product_id int not null;

-- identifyin missing values using is null functon
-- external_factors 
select 
sum(case when sales_date is null then 1 else 0 end)as missing_date,
sum(case when GDP is null then 1 else 0 end)as missing_gdp,
sum(case when inflation_rate is null then 1 else 0 end)as missing_inflation_rate,
sum(case when seasonal_factor is null then 1 else 0 end) as missing_seasonal_factor
from external_factors;

-- inventory_data
select 
	sum(case when product_id is null then 1 else 0 end) as missing_product_id,
    sum(case when sales_date is null then 1 else 0 end) as missing_sales_date,
    sum(case when inventory_quantity is null then 1 else 0 end) as missing_inventory,
    sum(case when product_cost is null then 1 else 0 end) as missing_product_cost,
    sum(case when product_category is null then 1 else 0 end) as missing_product_category,
    sum(case when promotions is null then 1 else 0 end) as missing_promotions,
    sum(case when gdp is null then 1 else 0 end) as missing_gdp,
    sum(case when inflation_rate is null then 1 else 0 end) as missing_inflation_rate,
    sum(case when seasonal_factor is null then 1 else 0 end) as missing_seasonal_factor
from inventory_data;

-- product_data
select
	sum(case when product_id is null then 1 else 0 end ) as missing_product_id,
    sum(case when product_category is null then 1 else 0 end) as missing_product_category,
    sum(case when promotions is null then 1 else 0 end) as promotions
from product_data;

-- sales data
select 
	sum(case when product_id is null then 1 else 0 end) as missing_product_id,
    sum(case when inventory_quantity is null then 1 else 0 end) as missinf_inventory,
    sum(case when product_cost is null then 1 else 0 end ) as missing_product_cost,
    sum(case when sales_date is null then 1 else 0 end ) as missing_sales_date
from sales_data;

-- checking for duplicates using group by and having function
-- external_factors
select sales_date, count(*) as count
from external_factors
group by sales_date
having count(*) > 1;

select count(*) 
from (select sales_date, count(*) as count
from external_factors 
group by sales_date
having count >1) as dup;

-- Product_data
select product_id, product_category, count(*) as count
from product_data
group by product_id, product_category
having count > 1 ;

select count(*)
from(select product_id, product_category, count(*) as count
from product_data
group by product_id, product_category
having count > 1 ) as dupl;

-- sales_data
select sales_date, product_id, count(*) as count
from sales_data
group by sales_date, product_id
having count > 1 ;

-- handlimg the missig value
-- external_factors 
delete e1 
from external_factors e1
inner join(
	select sales_date, 
        row_number() over(partition by sales_date order by sales_date) as rn 
from external_factors
) e2 on e1.sales_date = e2.sales_date 
where e2.rn > 1;

-- product_data 
delete p1
from product_data p1
inner join (
select product_id, 
   row_number() over( partition by product_id order by product_id) as rn
from product_data
) p2 on p1.product_id = p2.product_id
where p2.rn > 1;

-- Data Integration 
-- joining Sales data and Product data first 
create view sales_product_data as 
select  s.product_id, 
		s.Inventory_Quantity, 
		s.product_cost, 
		s.sales_date, 
		p.product_category,
        p.promotions
from sales_data s
join product_data p on s.product_id = p.product_id;

-- joining sales_product_data and external_factors
create view new_inventory_data as
select sp.product_id, 
		sp.Inventory_Quantity, 
		sp.product_cost, 
		sp.sales_date, 
		sp.product_category,
        sp.promotions,
        e.GDP,
        e.inflation_rate,
        e.seasonal_factor
from sales_product_data sp
left join external_factors e on sp.sales_date = e.Sales_date;

-- descriptive analysis
-- average sales(calculated as the product of inventory quantity and product cost )
select product_id, 
	avg(inventory_quantity * product_cost) as avg_sales
from new_inventory_data 
group by product_id 
order by avg_sales desc;

-- median stock levels ( i.e "inventory_quantity")
select product_id, avg(inventory_quantity) as median_stocks
from (select product_id, 
			 inventory_quantity,
row_number() over( partition by product_id order by inventory_quantity ) as row_num_asc,
row_number() over( partition by product_id order by inventory_quantity desc) as row_num_desc
from new_inventory_data 
) as subquery 
where row_num_asc in ( row_num_desc, row_num_desc -1,row_num_desc + 1)
group by product_id;

-- product performance metrics(total_sales per product)
select product_id,
		sum( inventory_quantity * product_cost) as total_sales
from new_inventory_data
group by product_id
order by total_sales desc;

-- High demand products based on avg sales
with highdemandproducts as(
select product_id, avg (inventory_quantity) as avg_sales
from new_inventory_data
group by product_id
having avg_sales > (
select avg( inventory_quantity)* 0.95 from sales_data
    )
)

-- calculate stockout frequency for high demand products
select s.product_id,
count(*) as stockout_frequency
from new_inventory_data s
where s.product_id in (select product_id from highdemandproducts)
and s.inventory_quantity = 0
group by s.product_id;

-- influence of external factors 
-- GDP 
select product_id,
	avg(case when GDP > 0 then inventory_quantity else null end) as avg_sales_positive_gdp,
    avg(case when GDP <= 0 then inventory_quantity else null end) as avg_salesa_non_positive_gdp
from new_inventory_data
group by product_id
having avg_sales_positive_gdp is not null;

-- inflation
select product_id,
    avg(case when inflation_rate > 0 then inventory_quantity else null end) as avg_sales_positive_inflation,
    avg(case when inflation_rate <= 0 then inventory_quantity else null end) as avg_salesa_non_positive_inflation
from new_inventory_data
group by product_id
having avg_sales_positive_inflation is not null;

-- Inventory Optimization 
-- determine the optimal reorder point for each product based on historical sales data and external factors
-- reorder point = lead time demand + safety stock
-- lead time demand = rolling average sales * lead time 
-- safety stock == z * lead time^-2 * standard deviation of demand
-- z= 1.645  constant lead time of 7days  with the aim of 95% service level.
With inventory_calculations as (
	select product_id,
    avg(rolling_avg_sales) as avg_rolling_sales,
    avg(rolling_variance) as avg_rolling_variance
from (
	select product_id,
    avg(daily_sales) over(partition by product_id order by sales_date rows between 6 preceding and current row ) as rolling_avg_sales,
    avg(squared_diff) over (partition by product_id order by sales_date rows between 6 preceding and current row) as rolling_variance
    from (
    select product_id,
    sales_date, inventory_quantity * product_cost as daily_sales,
    (inventory_quantity * product_cost - avg(inventory_quantity * product_cost) over (partition by product_id order by sales_date rows between 6 preceding and current row))
  * ( inventory_quantity * product_cost - avg(inventory_quantity * product_cost) over (partition by product_id order by sales_date rows between 6 preceding and current row)) as squared_diff
  from new_inventory_data
  ) subquery
   ) subquery2
	group by product_id
)
select product_id,
avg_rolling_sales * 7 as lead_time_demand,
	1.645 * (avg_rolling_variance * 7) as safety_stock,
(avg_rolling_sales * 7) + (1.645 * (avg_rolling_variance * 7)) as reorder_point 
from inventory_calculations;
    
-- create the inventory optimization table
create table inventory_optimization(
	product_id int,
	reorder_point double
);

-- step 2 create the stored procedure to recalculate reorder point 

delimiter //
create procedure recalculate_reorder_point (productid int)
begin
  declare avgrollingsales double;
  declare avgrollingvariance double;
  declare leadtimedemand double;
  declare safetystock double;
  declare reorderpoint double;
	select avg(rolling_avg_sales),avg(rolling_variance) 
    into avgrollingsales, avgrollingvariance
from (
	select product_id,
    avg(daily_sales) over(partition by product_id order by sales_date rows between 6 preceding and current row ) as rolling_avg_sales,
    avg(squared_diff) over (partition by product_id order by sales_date rows between 6 preceding and current row) as rolling_variance
    from (
    select product_id,
    sales_date, inventory_quantity * product_cost as daily_sales,
    (inventory_quantity * product_cost - avg(inventory_quantity * product_cost) over (partition by product_id order by sales_date rows between 6 preceding and current row))
  * ( inventory_quantity * product_cost - avg(inventory_quantity * product_cost) over (partition by product_id order by sales_date rows between 6 preceding and current row)) as squared_diff
  from new_inventory_data
  ) innerderived
   ) outerderived;
set leadtimedemand = avgrollingsales * 7;
set safetystock = 1.645 * sqrt(avgrollingvariance * 7);
set reorderpoint = leadtimedemand + safetystock ;
insert into inventory_optimization (product_id, reorder_point)
	values(productid, reorderpoint)
on duplicate key update reorder_point = reorderpoint;
End //
delimiter ;

-- make inventory data a permanent table
create table inventory_table as select * from new_inventory_data

-- step 4 create triger
delimiter //
create trigger afterinsertunifiedtable
after insert on inventory_table
for each row
begin 
call recalculatereorderpoint (new.product_id);
end //
delimiter //

-- Understocking and over stocking 
with rollingsales as (
select product_id,
sales_date,
avg (inventory_quantity * product_cost) over(partition by product_id order by sales_date rows between 6 preceding and current row) as rolling_avg_sales
from inventory_table
),
-- calculate the number of days a product was out of stock
stockoutdays as ( 
select product_id,
 count(*) as stockout_days 
from inventory_table
where inventory_quantity = 0
group by product_id
)
-- join the above CTEs with the main table to get the results 
select f.product_id,
avg( f.inventory_quantity * f.product_cost ) as avg_inventory_value,
avg(rs.rolling_avg_sales ) as avg_rolling_sales,
 coalesce(sd.stockout_days, 0) as stockout_days
from inventory_table f
join rollingsales rs on f.product_id = rs.product_id and f.sales_date = rs.sales_date
left join stockoutdays sd on f.product_id = sd.product_id
group by f.product_id, sd.stockout_days;

-- monitor and adjust 
-- monitor inventory levels 
delimiter //
create procedure monitorinventorylevels()
begin 
select product_id, avg( inventory_quantity) as avginventory
from inventory_table 
group by product_id
order by avginventory desc;
end //
delimiter ;

-- monitor sales trend 
delimiter //
create procedure monitorsalestrend()
begin
select product_id, sales_date,
avg(inventory_quantity* product_cost) over (partition by product_id order by sales_date rows between 6 preceding and current row) as rollingavgsales
from inventory_table
	order by product_id, sales_date;
end //
delimiter ;

-- monitor stockout frequencies
delimiter //
create procedure monitorstockout()
begin
select product_id, count(*) as stockoutdays
from inventory_table
where inventory_quantity = 0
group by product_id
order by stockoutdays desc;
end //
delimiter ;


-- Feedback loop

-- Feedback loop establishment
-- feedback portal: devlop an online platform for stake holders to easily submit feedback on inventory performance and challenges
-- Review meetings: Organize periodic sessions to discuss inventory system performance amd gather direct insights
-- System monitoring : Use established SQL procedures track system metrics, with deviations flagged for review

-- Refinement based on feedback
-- feeback analysis: regularly compile and scrutinize feedback to identify recurring themes or pressing issues
-- Action implementation: Priortize and act on the feedback to adjust reorder points, safety stock levels, or overall processes.
-- change communication: Inform stakeholders about changes, underscoring the value of their feedback and ensuring transparency.

-- General Insights 

-- Inventory discrepancies: The initial stages of the analysis revealed significant discrepancies in inventory levels, with instances of both overstocking and understocking.
-- These inconsistencies were contributing to capital inefficiencies and customer disatisfaction.

-- sales trends and external influences: The analysis indicated that sales trends were notably influenced by various external factors.
-- recognizing these patterns provides an opportunity to forecast demand more accurately.

-- Suboptimal inventory levels: through the inventory optimization analysis, it was evident that the existing inventory levels were not optimised for current sales trends.
-- products was identified that had either close excess inventory.alter


-- Recommendations:

-- 1. implement dynamic inventory management: The company should transition from a static to a dynamic inventory management system,
--    adjusting inventory levels based on real-time sales trends, seasonality and external factors.

-- 2. Optimize reorder points and safety stocks: utilize the reorder points and safety stocks calculated during the analysis to minimize stockouts and reduce excess inventory.
--    regualarly review these metrics to ensure they align with current market conditions.

-- 3. enhance pricing strategies: conduct a thorough review of product pricing strategies, especially for products identified as unprofitable.
--    consider factors such as competitor pricing, market demand and product acquisition costs.

-- 4. reduce overstock: identify products that are consistently overstocked and take steps to reduce their inventory levels.
