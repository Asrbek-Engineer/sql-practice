-- =================
-- leetcode - 50 sql
-- =================

-- 1757. Recyclable and Low Fat Products
-- https://leetcode.com/problems/recyclable-and-low-fat-products/description/?envType=study-plan-v2&envId=top-sql-50
select
    product_id
from products
where low_fats = 'Y' and recyclable = 'Y'

-- 584. Find Customer Referee
-- https://leetcode.com/problems/find-customer-referee/?envType=study-plan-v2&envId=top-sql-50
select customer.name
from customer
where referee_id != 2 or referee_id is null

-- 595. Big Countries
-- https://leetcode.com/problems/big-countries/description/?envType=study-plan-v2&envId=top-sql-50
select 
    w.name,
    w.population,
    w.area
from world w
where w.area >= 3000000 or w.population >= 25000000

-- 1148. Article Views I
-- https://leetcode.com/problems/article-views-i/description/?envType=study-plan-v2&envId=top-sql-50
select distinct v.author_id as id
from views v
where v.author_id = v.viewer_id
order by id

-- 1683. Invalid Tweets
-- https://leetcode.com/problems/invalid-tweets/?envType=study-plan-v2&envId=top-sql-50
select
    tweet_id 
from tweets
where len(content) > 15

-- 1378. Replace Employee ID With The Unique Identifier
-- https://leetcode.com/problems/replace-employee-id-with-the-unique-identifier/description/?envType=study-plan-v2&envId=top-sql-50
select
    eu.unique_id,
    e.name
from employees e 
left join employeeuni eu
    on e.id = eu.id

-- 1068. Product Sales Analysis I
-- https://leetcode.com/problems/product-sales-analysis-i/description/?envType=study-plan-v2&envId=top-sql-50
select 
    p.product_name,
    s.year,
    s.price
from sales s
inner join product p
    on s.product_id = p.product_id

-- 1581. Customer Who Visited but Did Not Make Any Transactions
-- https://leetcode.com/problems/customer-who-visited-but-did-not-make-any-transactions/?envType=study-plan-v2&envId=top-sql-50
select
    v.customer_id,
    count(v.customer_id) as count_no_trans 
from visits as v
left join transactions as t
    on t.visit_id = v.visit_id
where t.transaction_id is null
group by v.customer_id

-- 197. Rising Temperature
-- https://leetcode.com/problems/rising-temperature/?envType=study-plan-v2&envId=top-sql-50
select  
    w1.id
from weather as w
left join weather as w1
    on w.recorddate = dateadd(day, -1, w1.recorddate)
where w.temperature < w1.temperature

-- 620. Not Boring Movies
-- https://leetcode.com/problems/not-boring-movies/description/?envType=study-plan-v2&envId=top-sql-50
select
    id,
    movie,
    description,
    rating
from cinema
where id % 2 = 1 and description != 'boring'
order by rating desc

-- 1251. Average Selling Price
-- https://leetcode.com/problems/average-selling-price/?envType=study-plan-v2&envId=top-sql-50
select
    p.product_id,
    coalesce(
        round(
            sum(p.price * coalesce(u.units, 0)) / nullif(cast(sum(u.units) as decimal(10, 2)), 0), 
            2),
         0) as average_price 
from prices as p
left join unitssold as u
    on p.product_id = u.product_id
where u.purchase_date between p.start_date and p.end_date or u.product_id is null
group by p.product_id

-- 2356. Number of Unique Subjects Taught by Each Teacher
-- https://leetcode.com/problems/number-of-unique-subjects-taught-by-each-teacher/?envType=study-plan-v2&envId=top-sql-50
select
    teacher_id,
    count(distinct subject_id) as cnt
from Teacher
group by teacher_id

-- 1141. User Activity for the Past 30 Days I
-- https://leetcode.com/problems/user-activity-for-the-past-30-days-i/description/?envType=study-plan-v2&envId=top-sql-50
select
    activity_date as day,
    count(distinct user_id) as active_users
from activity
where activity_date > dateadd(day, -30, '2019-07-27')
    and activity_date <= '2019-07-27'
group by activity_date

-- 1075. Project Employees I
-- https://leetcode.com/problems/project-employees-i/?envType=study-plan-v2&envId=top-sql-50
select
    p.project_id,
    cast(avg(cast(e.experience_years as decimal(10, 2))) as decimal(10, 2)) as average_years
from project as p
inner join employee as e
    on p.employee_id = e.employee_id 
group by p.project_id
order by p.project_id

-- =================
-- other problems (not in SQL 50)
-- =================

-- 175. Combine Two Tables
-- https://leetcode.com/problems/combine-two-tables/description/
select
    p.firstname,
    p.lastname,
    a.city,
    a.state
from person p
left join address a
    on p.personid = a.personid

-- 183. Customers Who Never Order
-- https://leetcode.com/problems/customers-who-never-order/
select
    c.name as customers
from customers c
left join orders o
    on c.id = o.customerid
where o.id is null

-- 181. Employees Earning More Than Their Managers
-- https://leetcode.com/problems/employees-earning-more-than-their-managers/
select
    e1.name as employee
from employee e1
inner join employee e2
    on e1.managerid = e2.id
where e1.salary > e2.salary