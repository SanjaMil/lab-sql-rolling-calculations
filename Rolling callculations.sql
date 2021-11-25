use sakila;

-- Lab | SQL Rolling calculations
-- 1. Get number of monthly active customers.
select * from customer;
select * from payment;
-- active customer is customer who has some amount>0 in certain month, also month needs to be extracted from payment_date


-- subquery filtering active customers per month
select customer_id, date_format(convert(payment_date, date), '%Y') as year_, date_format(convert(payment_date, date), '%m') as month_, sum(amount)
from payment
group by 1,2,3
having sum(amount) > 0
order by 2,3;
 -- solution:
select year_, month_, count(customer_id) as numner_of_active_customers
from (
select customer_id, date_format(convert(payment_date, date), '%Y') as year_, date_format(convert(payment_date, date), '%m') as month_, sum(amount)
from payment
group by 1,2,3
having sum(amount) > 0
order by 2,3
) sub1
group by 1,2
order by 1,2;

-- 2. Active users in the previous month.

-- create a view that filters payment per date and customer_id
create or replace view customer_activity as
select customer_id, convert(payment_date, date) as Date_of_activity, date_format(convert(payment_date, date), '%Y') as year_of_activity, 
date_format(convert(payment_date, date), '%m') as month_of_activity, sum(amount) 
from payment
group by 1,2,3
having sum(amount) > 0
order by 2,3;

select * from customer_activity;

-- create a view of a number of monthly active customers
create or replace view Monthly_active_customers as
select Date_of_activity, year_of_activity, month_of_activity, count(customer_id) as Number_of_active_customers
from customer_activity
group by 1,2,3
order by 1,2,3;

select * from Monthly_active_customers;

-- create a view where we are adding column with active customers from previous month
-- solution
create or replace view Bi_monthly_customer_activity as
select *, LAG(Number_of_active_customers) over () as Last_month_active_customers
from Monthly_active_customers;

select * from Bi_monthly_customer_activity;

-- 3. Percentage change in the number of active customers.

select *, round(Number_of_active_customers/Last_month_active_customers-1, 1) as Difference
from Bi_monthly_customer_activity;

-- 4. Retained customers every month.
-- create a view with year, month customer_id, LAG(over customer id) and third columnf which is comparing, if 1-2 = 0 means retained customer and than count of third column


select * from customer_activity;
create or replace view retained_customers_1 as
	select
    customer_id, Date_of_activity,
    year_of_activity,
    month_of_activity
	from customer_activity;
select * from retained_customers_1;
create or replace view retained as
select r.customer_id, r.year_of_activity, r.month_of_activity
from retained_customers_1 r
join retained_customers_1 r1 ON r.customer_id = r1.customer_id
AND r.year_of_activity = r1. year_of_activity
and r.month_of_activity = r1.month_of_activity + 1;


select * from retained;


select year_of_activity, month_of_activity, count(customer_id)
from retained
group by 1,2
order by 1,2;