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

-- =================
-- other problems (not in SQL 50)
-- =================

-- 175. Combine Two Tables
-- https://leetcode.com/problems/combine-two-tables/description/
SELECT
    P.firstName,
    P.lastName,
    A.city,
    A.state
FROM Person P
LEFT JOIN Address A
    ON P.personId = A.personId
-- 183. Customers Who Never Order
-- https://leetcode.com/problems/customers-who-never-order/
SELECT 
    C.name AS Customers
FROM Customers C
LEFT JOIN Orders O
    ON C.id = O.customerId
WHERE O.id IS NULL
-- 181. Employees Earning More Than Their Managers
-- https://leetcode.com/problems/employees-earning-more-than-their-managers/
SELECT 
    E1.name AS Employee
FROM Employee E1
LEFT JOIN Employee E2
    ON E1.managerId = E2.id
WHERE E1.salary > E2.salary