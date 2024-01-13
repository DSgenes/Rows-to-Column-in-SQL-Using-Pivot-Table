/*

Pivot Table - Rows to Column in Sql

*/
drop table sales_data;
create table sales_data
            (sales_date date, customer_id varchar(10), amount varchar(50));

insert into sales_data
values      ('2021-01-01', 'Cust-1', '50$'),
            ('2021-01-02', 'Cust-1', '50$'),
			('2021-01-03', 'Cust-1', '50$'),
			('2021-01-01', 'Cust-2', '100$'),
			('2021-01-02', 'Cust-2', '100$'),
			('2021-01-03', 'Cust-2', '100$'),
			('2021-02-01', 'Cust-2', '-100$'),
			('2021-02-02', 'Cust-2', '-100$'),
			('2021-02-03', 'Cust-2', '-100$'),
			('2021-03-01', 'Cust-3', '1$'),
			('2021-04-01', 'Cust-3', '1$'),
			('2021-05-01', 'Cust-3', '1$'),
			('2021-06-01', 'Cust-3', '1$'),
			('2021-07-01', 'Cust-3', '-1$'),
			('2021-08-01', 'Cust-3', '-1$'),
			('2021-09-01', 'Cust-3', '-1$'),
			('2021-10-01', 'Cust-3', '-1$'),
			('2021-11-01', 'Cust-3', '-1$'),
			('2021-12-01', 'Cust-3', '-1$');
select * from sales_data;

--first of all we need to remove this dollar symbol in our base query we'll transform this date field such that
--we only fetch the month and year
--Base query
--there are certain rules to follow when coming up with a base query the first thing is the base query should have
--three columns atleast it can have more than three columns also the first name of your column should be a unique identifier
--for your row the second column should provide all the different values with which you basically be creating all the columns
--then finally the third column should be the value that will get loaded into each of this category that is returned from the 
--second column
select customer_id as customer
, format(sales_date, 'MMM-yy') as sales_date
, replace(amount, '$', '') as amount
from sales_data;

--Pivot Table 
--the aggregation of sales amount for each customer for each month 
select *
from
    (
	   select customer_id as customer
       , format(sales_date, 'MMM-yy') as sales_date
       , cast(replace(amount, '$', '') as int) as amount
from sales_data
    ) as sales_data
pivot
    (
	    sum(amount)
		for sales_date in ([Jan-21], [Feb-21], [Mar-21], [Apr-21], [May-21], [Jum-21], 
		                   [Jul-21], [Aug-21], [Sep-21], [Oct-21], [Nov-21], [Dec-21])
	) as pivot_table

--The next thing we need to do is to find the aggregation of sales amount for each month irrespective of the customer
--the base query will always provide the raw data based on this data sql will try to do the sum of amount and it'll try to create 
--multiple columns based on the values that are returned from this sales date and then each of these values will correspond to the values
--that is returned in the sales date column

--i just need to sum up all of this 12 columns and then that will be my total 
select *
from
    (
	   select customer_id as customer
       , format(sales_date, 'MMM-yy') as sales_date
       , cast(replace(amount, '$', '') as int) as amount
from sales_data
    ) as sales_data
pivot
    (
	    sum(amount)
		for sales_date in ([Jan-21], [Feb-21], [Mar-21], [Apr-21], [May-21], [Jun-21], 
		                   [Jul-21], [Aug-21], [Sep-21], [Oct-21], [Nov-21], [Dec-21])
	) as pivot_table 
UNION
select *
from 
    (
	   select 'Total' as customer
	   , format(sales_date, 'MMM-yy') as sales_date
       , cast(replace(amount, '$', '') as int) as amount
       from sales_data
    ) as sales_data
pivot
    (
	    sum(amount)
		for sales_date in ([Jan-21], [Feb-21], [Mar-21], [Apr-21], [May-21], [Jun-21], 
		                   [Jul-21], [Aug-21], [Sep-21], [Oct-21], [Nov-21], [Dec-21])
	) as pivot_table 

--now i need to transform this null into a zero
--to replace a null value with some other value we can use coalesce
--the query is already too big so we're using with clause now
with pivot_data as
    (select *
    from
    (
	   select customer_id as customer
       , format(sales_date, 'MMM-yy') as sales_date
       , cast(replace(amount, '$', '') as int) as amount
from sales_data
    ) as sales_data
pivot
    (
	    sum(amount)
		for sales_date in ([Jan-21], [Feb-21], [Mar-21], [Apr-21], [May-21], [Jun-21], 
		                   [Jul-21], [Aug-21], [Sep-21], [Oct-21], [Nov-21], [Dec-21])
	) as pivot_table 
UNION
select *
from 
    (
	   select 'Total' as customer
	   , format(sales_date, 'MMM-yy') as sales_date
       , cast(replace(amount, '$', '') as int) as amount
       from sales_data
    ) as sales_data
pivot
    (
	    sum(amount)
		for sales_date in ([Jan-21], [Feb-21], [Mar-21], [Apr-21], [May-21], [Jun-21], 
		                   [Jul-21], [Aug-21], [Sep-21], [Oct-21], [Nov-21], [Dec-21])
	) as pivot_table ),
final_data as
    (select customer
	, coalesce([Jan-21], 0) as Jan_21
	, coalesce([Feb-21], 0) as Feb_21
	, coalesce([Mar-21], 0) as Mar_21
	, coalesce([Apr-21], 0) as Apr_21
	, coalesce([May-21], 0) as May_21
	, coalesce([Jun-21], 0) as Jun_21
    , coalesce([Jul-21], 0) as Jul_21
	, coalesce([Aug-21], 0) as Aug_21
	, coalesce([Sep-21], 0) as Sep_21
	, coalesce([Oct-21], 0) as Oct_21
	, coalesce([Nov-21], 0) as Nov_21
	, coalesce([Dec-21], 0) as Dec_21
	from pivot_data)
select *
from final_data;

--the next thing i'll need to do is i need to sum up the values of these 12 columns or 12 months but i'll
--also do some additional transformation by adding a dollar symbol to the end of these amount values
--secondly where there are negative values i'll replace the negative with a parenthesis

with pivot_data as
    (select *
    from
    (
	   select customer_id as customer
       , format(sales_date, 'MMM-yy') as sales_date
       , cast(replace(amount, '$', '') as int) as amount
from sales_data
    ) as sales_data
pivot
    (
	    sum(amount)
		for sales_date in ([Jan-21], [Feb-21], [Mar-21], [Apr-21], [May-21], [Jun-21], 
		                   [Jul-21], [Aug-21], [Sep-21], [Oct-21], [Nov-21], [Dec-21])
	) as pivot_table 
UNION
select *
from 
    (
	   select 'Total' as customer
	   , format(sales_date, 'MMM-yy') as sales_date
       , cast(replace(amount, '$', '') as int) as amount
       from sales_data
    ) as sales_data
pivot
    (
	    sum(amount)
		for sales_date in ([Jan-21], [Feb-21], [Mar-21], [Apr-21], [May-21], [Jun-21], 
		                   [Jul-21], [Aug-21], [Sep-21], [Oct-21], [Nov-21], [Dec-21])
	) as pivot_table ),
final_data as
    (select customer
	, coalesce([Jan-21], 0) as Jan_21
	, coalesce([Feb-21], 0) as Feb_21
	, coalesce([Mar-21], 0) as Mar_21
	, coalesce([Apr-21], 0) as Apr_21
	, coalesce([May-21], 0) as May_21
	, coalesce([Jun-21], 0) as Jun_21
    , coalesce([Jul-21], 0) as Jul_21
	, coalesce([Aug-21], 0) as Aug_21
	, coalesce([Sep-21], 0) as Sep_21
	, coalesce([Oct-21], 0) as Oct_21
	, coalesce([Nov-21], 0) as Nov_21
	, coalesce([Dec-21], 0) as Dec_21
	from pivot_data)
select customer
, case when Jan_21 < 0 then concat('(', Jan_21 * -1, ')$') else concat(Jan_21, '$') end as "Jan-21"
, case when Feb_21 < 0 then concat('(', Feb_21 * -1, ')$') else concat(Feb_21, '$') end as "Feb-21"
, case when Mar_21 < 0 then concat('(', Mar_21 * -1, ')$') else concat(Mar_21, '$') end as "Mar-21"
, case when Apr_21 < 0 then concat('(', Apr_21 * -1, ')$') else concat(Apr_21, '$') end as "Apr-21"
, case when May_21 < 0 then concat('(', May_21 * -1, ')$') else concat(May_21, '$') end as "May-21"
, case when Jun_21 < 0 then concat('(', Jun_21 * -1, ')$') else concat(Jun_21, '$') end as "Jun-21"
, case when Jul_21 < 0 then concat('(', Jul_21 * -1, ')$') else concat(Jul_21, '$') end as "Jul-21"
, case when Aug_21 < 0 then concat('(', Aug_21 * -1, ')$') else concat(Aug_21, '$') end as "Aug-21"
, case when Sep_21 < 0 then concat('(', Sep_21 * -1, ')$') else concat(Sep_21, '$') end as "Sep-21"
, case when Oct_21 < 0 then concat('(', Oct_21 * -1, ')$') else concat(Oct_21, '$') end as "Oct-21"
, case when Nov_21 < 0 then concat('(', Nov_21 * -1, ')$') else concat(Jan_21, '$') end as "Nov-21"
, case when Dec_21 < 0 then concat('(', Dec_21 * -1, ')$') else concat(Jan_21, '$') end as "Dec-21"
, case when customer = 'Total' then ''
       else case when (Jan_21 + Feb_21 + Mar_21 + Apr_21 + May_21 + Jun_21 + Jul_21 + Aug_21 + Sep_21 + Oct_21 + Nov_21 + Dec_21) < 0
	   then concat ('(',(Jan_21 + Feb_21 + Mar_21 + Apr_21 + May_21 + Jun_21 + Jul_21 + Aug_21 + Sep_21 + Oct_21 + Nov_21 + Dec_21) * -1, ')$')
	   else concat ((Jan_21 + Feb_21 + Mar_21 + Apr_21 + May_21 + Jun_21 + Jul_21 + Aug_21 + Sep_21 + Oct_21 + Nov_21 + Dec_21), '$')
	end
end as Total
from final_data;

---------------------------------------------------------------------------------------------------------------------