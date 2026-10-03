/*
  LeetCode SQL solutions: JOINs
  Solutions were submitted and accepted on LeetCode (MS SQL Server).
  Table schemas are available on each problem page.
*/

-- LeetCode 175: Combine Two Tables (LEFT JOIN)
SELECT
    P.firstName,
    P.lastName,
    A.city,
    A.state
FROM Person P
LEFT JOIN Address A
    ON P.personId = A.personId

-- LeetCode 183: Customers Who Never Order (LEFT JOIN + IS NULL)
SELECT 
    C.name AS Customers
FROM Customers C
LEFT JOIN Orders O
    ON C.id = O.customerId
WHERE O.id IS NULL

-- LeetCode 181: Employees Earning More Than Their Managers (self join)
SELECT 
    E1.name AS Employee
FROM Employee E1
LEFT JOIN Employee E2
    ON E1.managerId = E2.id
WHERE E1.salary > E2.salary

-- LeetCode 1378: Replace Employee ID With The Unique Identifier (LEFT JOIN)
SELECT
    EU.unique_id,
    E.name
FROM Employees E 
LEFT JOIN EmployeeUNI EU
    ON E.id = EU.id

-- LeetCode 1068: Product Sales Analysis I (INNER JOIN)
SELECT 
    P.product_name,
    S.year,
    S.price
FROM Sales S
INNER JOIN Product P
    ON S.product_id = P.product_id