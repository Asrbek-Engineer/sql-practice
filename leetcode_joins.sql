/*
  LeetCode SQL solutions: JOINs
  Solutions were submitted and accepted on LeetCode (MS SQL Server).
  Table schemas are available on each problem page.
*/


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