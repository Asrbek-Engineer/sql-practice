/********************************************

	COMPARISON OPERATORS


	Equal (=): Find all products in the Production.Product table where the Color is exactly 'Black'.

	Not Equal (<>): Retrieve all products where the Class is not 'H'.

	Greater Than (>): Find all sales orders in Sales.SalesOrderHeader where the TaxAmt is greater than 10,000.

	Less Than or Equal (<=): List all products that have a SafetyStockLevel of 500 or less.

	Greater Than or Equal (>=): Find all products where the Weight is 50 or more.

********************************************/
-- 1
SELECT * FROM DimProduct
WHERE Color = 'Black'

--2
SELECT * FROM DimProduct
WHERE Class <> 'H'

--3
SELECT * FROM FactInternetSales
WHERE TaxAmt > 10000

--4
SELECT * FROM DimProduct
WHERE SafetyStockLevel <= 500

--5
SELECT * FROM DimProduct
WHERE Weight >= 50



/********************************************

	LOGICAL OPERATORS


	AND: Find all employees who are 'Male' AND have more than 50 VacationHours.

	OR: List products that are either 'Red' OR 'Blue'.

	NOT: Retrieve all employees who are NOT 'Salaried' (where SalariedFlag is 0).

	Complex AND/OR: Find all products that have a ListPrice greater than 1000 AND (a Color of 'Silver' OR 'Yellow').

	NOT + Comparison: Use the NOT operator to find orders where the TotalDue is not less than 5000.

********************************************/
--1
SELECT * FROM DimEmployee
WHERE Gender = 'M' AND VacationHours > 50

--2
SELECT * FROM DimProduct
WHERE Color = 'Red' OR Color = 'Blue'

--3
SELECT * FROM DimEmployee
WHERE NOT SalariedFlag != 0

--4
SELECT * FROM DimProduct
WHERE (ListPrice > 1000 AND (Color = 'Silver' OR Color = 'Yellow'))

--5
SELECT * FROM FactInternetSales
WHERE NOT TotalProductCost < 5000



/********************************************

	RANGE OPERATORS


	Numeric: Find all products with a StandardCost between 200 and 500.

	Date: Retrieve all orders from Sales.SalesOrderHeader placed between '2011-01-01' and '2011-12-31'.

	Inverse Range: Find products where the Weight is NOT between 5 and 20.

	Time-Based: Find orders with a ShipDate between '2012-07-01' and '2012-07-31'.

	Comparison Rewrite: Write a query that finds products with a ListPrice between 50 and 100, but do not use the word BETWEEN.

********************************************/
--1
SELECT * FROM DimProduct
WHERE StandardCost BETWEEN 200 AND 500

--2
SELECT * FROM FactInternetSales
WHERE OrderDate BETWEEN '2011-01-01' AND '2011-12-31'

--3
SELECT * FROM DimProduct
WHERE Weight NOT BETWEEN 5 AND 20

--4
SELECT * FROM FactInternetSales
WHERE ShipDate BETWEEN '2012-07-01' AND '2012-07-31'

--5
SELECT * FROM DimProduct
WHERE ListPrice >= 50 AND ListPrice <= 100



/********************************************

	MEMBERSHIP OPERATORS


	String List: Find all records in dbo.DimGeography where the EnglishCountryRegionName is 'United Kingdom', 'France', or 'Germany'.

	Numeric List: Retrieve all products from dbo.DimProduct where the ProductSubcategoryKey is exactly 1, 5, or 10.

	NOT IN: List all employees from dbo.DimEmployee whose DepartmentName is not 'Marketing', 'Engineering', or 'Finance'.

	Sales Filter: Select all records from dbo.FactInternetSales where the CurrencyKey is in (6, 19, 100).

	Logic Rewrite: Write a query to find resellers in dbo.DimReseller where the BusinessType is 'Warehouse' or 'Value Added Reseller' using OR instead of IN.
********************************************/
--1
SELECT * FROM DimGeography
WHERE EnglishCountryRegionName IN ('United Kingdom', 'France', 'Germany')

--2
SELECT * FROM DimProduct
WHERE ProductSubcategoryKey IN (1, 5, 10)

--3
SELECT * FROM DimEmployee
WHERE DepartmentName NOT IN ('Marketing', 'Engineering', 'Finance')

--4
SELECT * FROM FactInternetSales
WHERE CurrencyKey IN (6, 19, 100)

--5
SELECT * FROM DimReseller
WHERE BusinessType = 'Warehouse' OR BusinessType = 'Value Added Reseller'



/********************************************

	SEARCH OPERATORS


	Starts With: Find all customers in dbo.DimCustomer whose LastName starts with the letter 'R'.

	Ends With: Find all products in dbo.DimProduct whose EnglishProductName ends with the word 'Tire'.

	Contains: Retrieve all employees from dbo.DimEmployee whose EmailAddress contains the word 'adventure'.

	Fixed Position: Find all products in dbo.DimProduct where the ProductAlternateKey has 'BK' as the first two characters and 'M' as the 4th character (e.g., BK-M...).

	Wildcard Combo: Find all customers in dbo.DimCustomer whose FirstName starts with 'C', ends with 'e', and has exactly 5 letters total (Hint: use the underscore _ for the three middle characters).
********************************************/
--1
SELECT * FROM DimCustomer
WHERE LastName LIKE 'R%'

--2
SELECT * FROM DimProduct
WHERE EnglishProductName LIKE '%Tire'

--3
SELECT * FROM DimEmployee
WHERE EmailAddress LIKE '%adventure%'

--4
SELECT * FROM DimProduct
WHERE ProductAlternateKey LIKE 'BK_M%'

--5
SELECT * FROM DimCustomer
WHERE FirstName LIKE 'C___e'



/*************************************************
		
		BEAUTIFUL CHALLENGES

		The "High-Value European" Filter:
	Find all geography records (DimGeography) where the EnglishCountryRegionName is either 'France' or 'Germany' AND the PostalCode starts with the digit '7'.

		The "Middle Management" Search:
	Find employees (DimEmployee) who have a BaseRate between 30 and 50 AND whose Title contains the word 'Manager' but does NOT end with the letter 's'.

		The "Legacy Product" Cleanup:
	Retrieve products (DimProduct) that have a Color of 'Silver', 'Black', or 'White' AND whose ProductAlternateKey starts with 'BK' BUT the StandardCost is not greater than 1000.

		The "Quarterly Sales" Audit:
	From FactInternetSales, find all rows where the OrderDate is in the first quarter of 2013 (January through March) AND the TaxAmt is less than or equal to Freight.

		The "Specific Customer" Drilldown:
	Find customers (DimCustomer) where the FirstName is exactly 4 letters long, starts with 'J', ends with 'n', AND the YearlyIncome is 100,000 or more.

*************************************************/
--1
SELECT * FROM DimGeography
WHERE EnglishCountryRegionName IN ('France', 'Germany') AND PostalCode LIKE '7%'

--2
SELECT * FROM DimEmployee
WHERE (BaseRate BETWEEN 30 AND 50) AND (Title LIKE '%Manager%' AND Title NOT LIKE '%s')

--3
SELECT * FROM DimProduct
WHERE Color IN ('Silver', 'Black', 'White') AND ProductAlternateKey LIKE 'BK%' AND NOT StandardCost > 1000 

--4
SELECT * FROM FactInternetSales
WHERE (OrderDate BETWEEN '2013-01-01' AND '2013-03-31') AND (TaxAmt <= Freight)

--5
SELECT * FROM DimCustomer
WHERE FirstName LIKE 'J__n' AND YearlyIncome >= 100000