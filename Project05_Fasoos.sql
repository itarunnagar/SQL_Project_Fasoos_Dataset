-- Use the Database..
use Project05_Fasoos ;

--Fasoos  is Basically a online food ordereding company..Just like Zomato and Swiggy...

--Create Table..
drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');

--Create Table..
drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

--Create Table..
drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');


--Create Table
drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

--Create Table..
drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,
distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2021 21:30:45','25km','25mins',null),
(8,2,'01-10-2021 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2021 18:50:20','10km','10minutes',null);

--Create Table..
drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,
not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');


--See All The DataBases..
select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

--COunts Numbers of Rows..
select count(*) as Total_Orders from customer_orders;
select count(*) as Numbers_of_Drivers from driver;
select count(*) as Total_Rolls from rolls;


--In Four Major Parts We Are Working in these Projects..
--A.Rolls Metrics
--B.Driver And Customer Ingredients
--C.Ingredients and Optimizations
--D.Pricing And Rating..



-- in these we also have to do data cleaning because these data was messy...There was lot of null and nan values presents..


--A.Rolls Metrics
--Total_Order
select COUNT(*) as Total__Orders from  customer_orders ; 


--Unique_Customer_That_Orders
select count(distinct customer_id) as Unique_Customer_That_Orders from customer_orders ; 

--ORder per Customers..
select customer_id , count(order_id)  as Numbers_of_orders
from customer_orders
group by customer_id
order by Numbers_of_orders desc; 

--Successfully  ordered deleivered to each customers..
select driver_id , sum(Cancelled_or_Not) as Numbers_of_Successfully_order_Delivered
from (select *  ,case when cancellation in ('cancellation' , 'customer cancellation') then 0
else 1 
end as Cancelled_or_Not
from driver_order) A 
group by driver_id 
order by Numbers_of_Successfully_order_Delivered desc;
 

--Which Rolls Order Most By Customers  --Mostly Non Veg Order ..
select b.roll_name , count(b.roll_name) as Numbers_of_Orders
from customer_orders a join rolls b
on a.roll_id = b.roll_id 
group by b.roll_name ; 


--Order Percantage
select * , ((ABC.Numbers_of_Orders/ABC.Total_orders)*100) as Order_Percantage
from (select b.roll_name , (select count(*) from customer_orders ) as Total_orders ,count(b.roll_name) as Numbers_of_Orders
from customer_orders a join rolls b
on a.roll_id = b.roll_id 
group by b.roll_name ) ABC ; 


--Successfully Deleivered Rolls
select roll_id , count(order_date) as Numbers_of_Succesfully_deleivered_orders
from customer_orders
where order_id in (select order_id
from (select *  ,case when cancellation in ('cancellation' , 'customer cancellation') then 0
else 1 
end as Cancelled_or_Not
from driver_order) ABC
where Cancelled_or_Not = 1) 
group by roll_id ;

--Veg And non Veg Order Per Customers..
select a.customer_id , b.roll_name  , count( b.roll_name) as Numbers_of_Orders
from customer_orders a join rolls b 
on a.roll_id = b.roll_id 
group by a.customer_id  , b.roll_name   
order by a.customer_id; 


--Maximum Rolls Delivered in ONe Orders..
select top 1 order_id , count(order_id) as Numbers_of_Order
from customer_orders group by order_id order by Numbers_of_Order desc ;


--For Each Customers How many delivered rolls  had at least  1 change and how many had no changes..
With Ab as (
select * , case when not_include_items is null or not_include_items = ' ' then  0
else 1 
end as Change_not_include_items , 
case when extra_items_included is null or extra_items_included = ' ' or 
extra_items_included = 'NaN' then 0 else 1
end as Change_Extra_item
from customer_orders )   -- CTE Ended...-- CTE Ended..-- CTE Ended..-- CTE Ended..-- CTE Ended..
-- CTE Ended..-- CTE Ended..-- CTE Ended..-- CTE Ended..-- CTE Ended..-- CTE Ended..-- CTE Ended..
select a.customer_id , a.roll_id , sum(Change_Extra_item + Change_not_include_items) as Numbers_of_Times_Changes
, count(roll_id) as Numbers_of_orders
from AB A inner join  (select *
from(
select * , case when cancellation in ('Cancellation' , 'Customer Cancellation') then 0
else 1 
end as Delivered_or_not
from driver_order) AB
where Delivered_or_not = 1) B 
on a.order_id =  b.order_id
group by a.customer_id , a.roll_id ;



--How Many Deleivered Rolls That Had Both Excluision And Extras.
With Ab as (
select * , case when not_include_items is null or not_include_items = ' ' then  0
else 1 
end as Change_not_include_items , 
case when extra_items_included is null or extra_items_included = ' ' or 
extra_items_included = 'NaN' then 0 else 1
end as Change_Extra_item
from customer_orders )   -- CTE Ended...-- CTE Ended..-- CTE Ended..-- CTE Ended..-- CTE Ended..
-- CTE Ended..-- CTE Ended..-- CTE Ended..-- CTE Ended..-- CTE Ended..-- CTE Ended..-- CTE Ended..
select order_date , order_id , customer_id , roll_id 
from AB 
where Change_Extra_item = 1 and Change_not_include_items = 1 ;



--Total Numbers of Rolls Ordered For Each Hour of the Day..
select  a.Hour_BUcket , count(distinct a.order_id) as Numbers_of_orders
from (select * , day(order_date) as Dates , 
concat(DATEPART(HOUR, order_date) , '-'  , (DATEPART(HOUR, order_date)+1)) as Hour_BUcket
from customer_orders) A inner join (select *
from (select * , case when cancellation in ('Cancellation' , 'Customer Cancellation') then 0
else 1 
end as Cancelled_or_not
from driver_order) ABCDE
where Cancelled_or_not = 1) B
on a.order_id = b.order_id 
group by a.Hour_BUcket;



--What Was the Numbers of Orders for each day of   the week...
select   DayNames , count(distinct a.order_id) as Numbers_of_orders
from (select * ,  datename(dw, order_date) AS DayNames
from customer_orders) A inner join (select *
from (select * , case when cancellation in ('Cancellation' , 'Customer Cancellation') then 0
else 1 
end as Cancelled_or_not
from driver_order) ABCDE
where Cancelled_or_not = 1) B
on a.order_id = b.order_id 
group by a.DayNames 
order by DayNames ;

--What Was Average Times in Minutes it took for  each driver to arrive at the 
--Fasoos HQ To pick up the orders 
select * , DENSE_RANK() over(order by Average_Times ) as Rnks
from (select driver_id , count(distinct order_id) as Numbers_of_Orders , 
(sum(TimeDifferenceInMinutes)/count(distinct order_id)) as Average_Times
from (select a.order_id , b.driver_id , a.order_date , b.pickup_time , 
DATEDIFF(MINUTE, a.order_date, b.pickup_time) AS TimeDifferenceInMinutes
from customer_orders a inner join driver_order b
on a.order_id = b.order_id 
where b.pickup_time is not null) ABCDE
group by driver_id) DEF ; 

 
-- IS there any relation ship between the rolls and how long the order takes to prepare..
--So Here we can see to prepare one roll order it will take approax 10 minute and whenver the order
--increases time multiply the order quantity
select order_id , count(roll_id) as Numbers_of_Rolls , 
(sum(Time_Diff)/count(roll_id)) as Time_Taken_To_Prepare
from(select a.order_id , customer_id , driver_id, roll_id , 
DATEDIFF(MINUTE , a.order_date , b.pickup_time) as Time_Diff
from customer_orders a inner join driver_order b 
on a.order_id = b.order_id
where b.pickup_time is not null ) ABC
group by order_id
order by Numbers_of_Rolls ;

--Average Distance For Each Customers
select customer_id , sum(Distances)/count(order_date) as Average_Distance_Per_Customer
from (select * , CAST(New_Distance AS float) as Distances
from(select * , REPLACE(distance , 'km' , '') as New_Distance
from (select * , ROW_NUMBER() over(partition by order_id order by order_date) as Rnks
from(select a.order_id , a.customer_id , b.driver_id , b.distance , order_date
from customer_orders a inner join driver_order b 
on a.order_id = b.order_id 
where b.pickup_time is not null ) ABC) CDE
where Rnks = 1)CFG) GHI 
group by customer_id ;

--Difference between the longest and shortest delivery time for all orders? 
select min(New_duration) as Minimum_Duration , max(New_duration) as Maximum_Duration , 
(max(New_duration) - min(New_duration) ) as Diff_Between_Min_MAx
from (select * , cast(REPLACE(REPLACE(REPLACE(duration, 'minutes', ''), 'minute', ''), 'mins', '') as float) AS New_duration
from driver_order where pickup_time is not null) ABC 

--Upper Same Question By USing Case Statements
SELECT 
    MIN(New_Duration) AS Minimum_Distance, 
    MAX(New_Duration) AS Maximum_Distance, 
    MAX(New_Duration) - MIN(New_Duration) AS Difference_Between_Min_Max
FROM (
    SELECT 
        CAST(
            CASE 
                WHEN New_Duration LIKE '%min%' THEN LEFT(New_Duration, CHARINDEX('m', New_Duration) - 1)
                ELSE New_Duration
            END 
            AS FLOAT
        ) AS New_Duration
    FROM (
        SELECT 
            *,
            CASE 
                WHEN duration LIKE '%min%' THEN LEFT(duration, CHARINDEX('m', duration) - 1)
                ELSE duration
            END AS New_Duration
        FROM driver_order
        WHERE pickup_time IS NOT NULL
    ) AS ABCDE
) AS BHDE;



--Average Speed for each driver for each delivery and do you notice any trend of these values..?
--First of all we have to find the speed...
select customer_id , driver_id , count(order_date) as Numbers_of_orders , 
avg(Speed) as Average_Speed_per_Customer
from (select * , round((new_distance/Duration_in_hrs),2) as Speed
from (select a.order_id , a.driver_id, b.order_date , b.customer_id , a.new_distance , round(a.new_duration/60 , 2)  as Duration_in_hrs , 
ROW_NUMBER() over(partition by b.order_id order by b.order_date) as Rnks
from (select * , cast(REPLACE(distance , 'km' , '')as float) as New_Distance , 
cast(case when duration like '%min%' then left(duration , CHARINDEX('m' , duration) - 1)
else duration  end as float)as New_Duration 
from driver_order where pickup_time is not null )a inner join customer_orders b 
on a.order_id = b.order_id ) GHI
where Rnks = 1) ZHI
group by customer_id , driver_id ; 
