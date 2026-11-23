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

-- 1633. Percentage of Users Attended a Contest
-- https://leetcode.com/problems/percentage-of-users-attended-a-contest/description/?envType=study-plan-v2&envId=top-sql-50
select
    contest_id,
    cast(100.0 * count(*) / (select count(*) from users) as decimal(10, 2)) as percentage
from register
group by contest_id
order by percentage desc, contest_id

-- 1211. Queries Quality and Percentage
-- https://leetcode.com/problems/queries-quality-and-percentage/?envType=study-plan-v2&envId=top-sql-50
-- v1 (my solution): correlated subquery, reads the table once per group
select
    q.query_name,
    cast(sum(cast(rating as decimal(10, 2)) / cast(q.position as decimal(10, 2))) / count(q.query_name) as decimal(10, 2)) as quality,
    cast(100.0 * (
        select count(q2.rating)
        from queries as q2
        where q2.rating < 3 and q.query_name = q2.query_name
    ) / cast(count(q.query_name) as decimal(10, 2)) as decimal(10, 2)) as poor_query_percentage
from queries as q
group by q.query_name;

-- v2 (improved): conditional aggregation, one pass over the table
-- pattern: share of rows matching a condition = avg(case when condition then 1 else 0 end)
select
    query_name,
    cast(avg(cast(rating as decimal(10, 2)) / position) as decimal(10, 2)) as quality,
    cast(avg(case when rating < 3 then 100.0 else 0 end) as decimal(10, 2)) as poor_query_percentage
from queries
where query_name is not null
group by query_name;

-- 180. Consecutive Numbers
-- https://leetcode.com/problems/consecutive-numbers/?envType=study-plan-v2&envId=top-sql-50
-- idea: a number appears 3 times in a row if it equals both the previous and the next row (lag + lead)
select
    distinct ConsecutiveNums
from (
    select
        case
            when num = lag(num) over(order by id)
             and num = lead(num) over(order by id) then num
        end as ConsecutiveNums
    from Logs
) t
where ConsecutiveNums is not null

-- 1729. Find Followers Count
-- https://leetcode.com/problems/find-followers-count/?envType=study-plan-v2&envId=top-sql-50
select
    user_id,
    count(follower_id) as followers_count
from Followers
group by user_id
order by user_id

-- 619. Biggest Single Number
-- https://leetcode.com/problems/biggest-single-number/?envType=study-plan-v2&envId=top-sql-50
select
    max(num) as num
from(
    select
        num
    from MyNumbers
    group by num
    having count(num) = 1
)t

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

-- 178. Rank Scores
-- https://leetcode.com/problems/rank-scores/
-- v1 (my solution): dense_rank is correct (no gaps after ties: 1, 2, 2, 3)
select
    score,
    dense_rank() over(order by score desc) as rank
from Scores

-- v2 (fixed): the window order by only numbers the rows,
-- the final order by sorts the result (required by the task)
select
    score,
    dense_rank() over(order by score desc) as [rank]
from Scores
order by score desc