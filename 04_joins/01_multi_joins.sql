-- MULTIPLE JOINS
/* Task: Using SalesDB, Retrieve a list of all orders, along with the related customer, product, and employee details.
For each order display: Order ID, Customer's name, Product name, Sales, Price, Sales person's name */
SELECT
	O.OrderID,
	O.Sales,
	C.FirstName + ' ' + C.LastName AS CustomerFullName,
	P.Product AS ProductName,
	P.Price,
	E.FirstName + ' ' + E.LastName AS EmployeeFullName
FROM Sales.Orders O
LEFT JOIN Sales.Customers C
ON O.CustomerID = C.CustomerID
LEFT JOIN Sales.Products P
ON O.ProductID = P.ProductID
LEFT JOIN Sales.Employees E
ON O.SalesPersonID = E.EmployeeID