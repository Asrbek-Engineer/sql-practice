/***************************************************************************************************

				CHALLENGES FOR INNER, LEFT, RIGHT AND FULL JOINS

***************************************************************************************************/

/*
Phase 1: The Basics (Inner & Left Joins)
1. Customer Locations: Join DimCustomer with DimGeography to show the first name, last name, and the City each customer lives in.

2. Product Categorization: Join DimProduct with DimProductSubcategory to list all product names and their corresponding subcategory names.

3. Internet Sales Overview: Join FactInternetSales with DimProduct. Display the SalesOrderNumber and the EnglishProductName.

4. Employee Departments: Join DimEmployee with DimDepartmentGroup. List each employee's name and the department they belong to.

5. Empty Categories (Left Join): List all DimProductSubcategory names and 
any DimProduct names associated with them. Ensure subcategories with no products are still visible in the list.
*/
-- 1
SELECT 
	C.FirstName, 
	C.LastName, 
	G.City 
FROM DimCustomer C
INNER JOIN DimGeography G
	ON C.GeographyKey = G.GeographyKey

-- 2
SELECT * 
FROM DimProduct P
INNER JOIN DimProductSubcategory PS
	ON P.ProductSubcategoryKey = PS.ProductSubcategoryKey

-- 3
SELECT
	FI.SalesOrderNumber,
	P.EnglishProductName
FROM FactInternetSales FI
INNER JOIN DimProduct P
	ON FI.ProductKey = P.ProductKey

-- 4
SELECT
	E.FirstName + ' ' + E.LastName AS FullName,
	DP.DepartmentGroupName
FROM DimEmployee E
INNER JOIN DimDepartmentGroup DP
	ON E.EmployeeKey = DP.DepartmentGroupKey

-- 5
SELECT *
FROM DimProductSubcategory PS
LEFT JOIN DimProduct P
	ON PS.ProductSubcategoryKey = P.ProductSubcategoryKey


/*
Phase 2: Intermediate (Multiple Joins & Filtering)
6. The Sales "Star": Join FactInternetSales with both DimProduct and DimCustomer. Show the customer's full name, the product they bought, and the sales amount.

7. Geography Deep-Dive: Join DimCustomer, DimGeography, and DimSalesTerritory. List customers and the name of the SalesTerritoryRegion they belong to.

8. Regional Sales Performance: Join FactResellerSales with DimSalesTerritory. Find the total SalesAmount for the 'Northwest' region.

9. Dated Sales: Join FactInternetSales with DimDate. Filter the results to only show sales that 
occurred on a weekend (SpanishDayNameOfWeek or FrenchDayNameOfWeek logic, or simply use the DayNumberOfWeek column).

10. Product Catalog Audit: Join DimProduct, DimProductSubcategory, and DimProductCategory. List every product and its full path (Category -> Subcategory -> Product).
*/
SELECT * FROM DimCustomer
SELECT * FROM DimGeography
SELECT * FROM DimSalesTerritory

-- 6
SELECT 
	FI.SalesOrderNumber,
	FI.SalesAmount,
	P.EnglishProductName,
	C.FirstName + ' ' + C.LastName AS CustomerFullName,
	C.EmailAddress
FROM FactInternetSales FI
INNER JOIN DimProduct P
	ON FI.ProductKey = P.ProductKey
INNER JOIN DimCustomer C
	ON FI.CustomerKey = C.CustomerKey

-- 7
SELECT 
	C.FirstName + ' '+ C.LastName AS CustomerFullName,
	ST.SalesTerritoryRegion
FROM DimCustomer C
INNER JOIN DimGeography G
	ON C.GeographyKey = G.GeographyKey
INNER JOIN DimSalesTerritory ST
	ON G.SalesTerritoryKey = ST.SalesTerritoryKey

-- 8
SELECT 
	RS.SalesAmount,
	ST.SalesTerritoryRegion
FROM FactResellerSales RS
INNER JOIN DimSalesTerritory ST
	ON RS.SalesTerritoryKey = ST.SalesTerritoryKey
WHERE ST.SalesTerritoryRegion = 'Northwest'

-- 9
SELECT
	FIS.SalesOrderNumber,
	FIS.SalesAmount,
	D.EnglishDayNameOfWeek
FROM FactInternetSaleS FIS
INNER JOIN DimDate D
	ON FIS.OrderDateKey = D.DateKey
WHERE D.DayNumberOfWeek IN (1, 7) -- Numbers are faster for the CPU to compare than strings

-- 10
SELECT
	PC.EnglishProductCategoryName AS Category,
	PS.EnglishProductSubcategoryName as Subcategory,
	P.EnglishProductName AS Product,
	P.ModelName,
	P.Color
FROM DimProduct P
INNER JOIN DimProductSubcategory PS
	ON P.ProductSubcategoryKey = PS.ProductSubcategoryKey
INNER JOIN DimProductCategory PC
	ON PS.ProductCategoryKey = PC.ProductCategoryKey


/*
Phase 3: Advanced (Fact Tables & Aggregations)
11. Reseller Reach: Join FactResellerSales with DimReseller. Show the ResellerName and the total number of orders each reseller has placed.

12. Currency Impact: Join FactInternetSales with DimCurrency. Show the SalesAmount and the CurrencyName used for each transaction.

13. Low Inventory Alert: Join FactProductInventory with DimProduct. Show products where the UnitsBalance is below 10.

14. Employee Managers (Self-Join): Using DimEmployee, join the table to itself to show the name of each employee and the name of their manager (Hint: Use ParentEmployeeKey).

15. Top Spending Customers: Join FactInternetSales with DimCustomer. Group by the customer's name and find the top 5 customers by total SalesAmount.
*/

-- Sorry I haven't learned Aggregate functions yet because of course structure (I will send you solutions as soon as learn theme)


/*
Phase 4: Mastery (Full Joins & Warehouse Logic)
16. Promotion Analysis (Full Join): Join FactInternetSales with DimPromotion. 
Write a query that shows all sales and their promotions, but also includes promotions that were never used and sales that had no promotion.

17. Financial Reporting: Join FactFinance with DimAccount and DimOrganization. Show the AccountDescription, the OrganizationName, and the Amount.

18. Sales vs. Quota: Join FactSalesQuota with DimEmployee. 
Compare an employee's SalesAmountQuota against their actual sales from FactResellerSales (this will require a JOIN on EmployeeKey).

19. Prospective Buyers: Join DimProspectiveBuyer with DimGeography. Find out which cities have the highest number of potential "prospective" customers who haven't bought anything yet.

20. The "Everything" Join: Create a report that joins FactInternetSales, DimProduct, DimCustomer, DimGeography, and DimDate. 
The output should show Sales Amount by Product Category, Customer City, and Calendar Year.
*/
-- 16
SELECT
	FIS.SalesOrderNumber,
	FIS.SalesAmount,
	PRO.EnglishPromotionType
FROM FactInternetSales FIS
FULL JOIN DimPromotion PRO
	ON FIS.ProductKey = PRO.PromotionKey

-- 17
SELECT
	A.AccountDescription,
	O.OrganizationName,
	F.Amount
FROM FactFinance F
FULL JOIN DimAccount A
	ON F.AccountKey = A.AccountKey
FULL JOIN DimOrganization O
	ON A.AccountKey = O.CurrencyKey

-- 18
SELECT
	SQ.SalesAmountQuota,
	RS.SalesAmount,
	E.FirstName + ' ' + E.LastName AS FullName
FROM FactSalesQuota SQ
FULL JOIN DimEmployee E
	ON SQ.EmployeeKey = E.EmployeeKey
FULL JOIN FactResellerSales RS
	ON SQ.EmployeeKey = RS.EmployeeKey
-- 19
SELECT
	G.City,
	PB.YearlyIncome
FROM ProspectiveBuyer PB
FULL JOIN DimGeography G
	ON PB.ProspectiveBuyerKey = G.GeographyKey
WHERE PB.YearlyIncome = (SELECT MAX(ProspectiveBuyer.YearlyIncome) FROM ProspectiveBuyer) 

-- 20
SELECT
	P.ProductSubcategoryKey,
	G.City,
	D.CalendarYear,
	FIS.SalesAmount
FROM FactInternetSales FIS
FULL JOIN DimProduct P
	ON FIS.ProductKey = P.ProductKey
FULL JOIN DimCustomer C
	ON P.ProductKey = C.CustomerKey
FULL JOIN DimGeography G
	ON C.GeographyKey = G.GeographyKey
FULL JOIN DimDate D
	ON G.GeographyKey = D.DateKey

/*
21. The "Ghost" Products (Left Join)
Find all products in DimProduct that have never been sold.

Goal: Use a LEFT JOIN between DimProduct and FactInternetSales and filter for where the Sales key is NULL.

22. The "Who's the Boss?" (Self-Join)
This is a classic interview question. Use DimEmployee to list every employee’s name alongside their Manager’s name.

Hint: Join DimEmployee (as E) to DimEmployee (as M) ON E.ParentEmployeeKey = M.EmployeeKey.

23. The Shipping Delay (Double Join)
In FactInternetSales, you have OrderDateKey and ShipDateKey. 
Join DimDate twice to show the actual calendar date for both the Order and the Shipment in the same row.

Hint: You will need to alias DimDate twice (e.g., FROM ... JOIN DimDate AS OrderDate ... JOIN DimDate AS ShipDate).

24. Regional "Orphans" (Right Join)
Identify if there are any SalesTerritoryRegion names in DimSalesTerritory that have no customers living in them.

Goal: Use a RIGHT JOIN starting from DimCustomer to DimSalesTerritory to find the empty regions.

25. The Product Category Audit
List all DimProductCategory names, their DimProductSubcategory names, and the count of products in each.

Note: Since you haven't done GROUP BY yet, just write the join logic to 
connect all three tables ensuring that even categories with no subcategories appear.
*/
-- 21
SELECT * 
FROM DimProduct P
LEFT JOIN FactInternetSales FIS
	ON P.ProductKey = FIS.ProductKey
WHERE FIS.SalesOrderNumber IS NULL

-- 22
SELECT 
	E.FirstName + ' ' + E.LastName AS EmployeeName,
	E.Title,
	M.FirstName + ' ' + M.LastName AS ManagerName,
	M.Title
FROM DimEmployee E
LEFT JOIN DimEmployee M
	ON E.ParentEmployeeKey = M.EmployeeKey

SELECT * FROM DimEmployee

-- 23
SELECT
	FIS.SalesOrderNumber,
	OD.FullDateAlternateKey AS OrderDate,
	SHD.FullDateAlternateKey AS ShipDate
FROM FactInternetSales FIS
RIGHT JOIN DimDate AS OD
	ON FIS.OrderDateKey = OD.DateKey
RIGHT JOIN DimDate AS SHD
	ON FIS.ShipDateKey = SHD.DateKey

-- 24
SELECT * FROM DimCustomer
SELECT * FROM DimSalesTerritory
SELECT 
	ST.SalesTerritoryKey,
	ST.SalesTerritoryGroup,
	C.CustomerKey
FROM DimCustomer C
RIGHT JOIN DimGeography G
	ON C.GeographyKey = G.GeographyKey
RIGHT JOIN DimSalesTerritory ST
	ON G.SalesTerritoryKey = ST.SalesTerritoryKey

-- EXTERNAL TASKS
-- 1
SELECT * FROM DimProduct
SELECT * FROM DimProductSubcategory
SELECT * FROM DimProductCategory

SELECT
	P.EnglishProductName,
	PS.EnglishProductSubcategoryName,
	PC.EnglishProductCategoryName
FROM DimProduct P
INNER JOIN DimProductSubcategory PS
	ON P.ProductSubcategoryKey = PS.ProductSubcategoryKey
INNER JOIN DimProductCategory PC
	ON PS.ProductCategoryKey = PC.ProductCategoryKey

-- 2
SELECT
	C.FirstNamE,
	C.LastName,
	G.City,
	ST.SalesTerritoryRegion
FROM DimCustomer C
INNER JOIN DimGeography G
	ON C.GeographyKey = G.GeographyKey
INNER JOIN DimSalesTerritory ST
	ON G.SalesTerritoryKey = ST.SalesTerritoryKey

-- 3
SELECT 
	FIS.SalesOrderNumber,
	P.EnglishProductName,
	FIS.SalesAmount
FROM FactInternetSales FIS
INNER JOIN DimProduct P
	ON FIS.ProductKey = P.ProductKey

-- 4
SELECT 
	FIS.SalesOrderNumber,
	P.EnglishProductName,
	C.LastName
FROM FactInternetSales FIS
INNER JOIN DimCustomer C
	ON FIS.CustomerKey = C.CustomerKey
INNER JOIN DimProduct P
	ON FIS.ProductKey = P.ProductKey

-- 5
SELECT 
	FIS.SalesOrderNumber,
	G.City
FROM FactInternetSales FIS
INNER JOIN DimCustomer C
	ON FIS.CustomerKey = C.CustomerKey
INNER JOIN DimGeography G
	ON C.GeographyKey = G.GeographyKey

-- 6
SELECT
	E.FirstName,
	DP.DepartmentGroupName
FROM DimEmployee E
INNER JOIN DimDepartmentGroup DP
	ON E.EmployeeKey = DP.DepartmentGroupKey

-- 7
SELECT
	FIS.SalesOrderNumber,
	OD.FullDateAlternateKey AS OrderDate,
	SHD.FullDateAlternateKey AS ShipDate
FROM FactInternetSales FIS
INNER JOIN DimDate OD
	ON FIS.OrderDateKey = OD.DateKey
INNER JOIN DimDate SHD
	ON FIS.ShipDateKey = SHD.DateKey

-- 8
SELECT 
	E2.FirstName + ' ' + E2.LastName AS EmployeeFullname,
	E1.FirstName + ' ' + E1.LastName AS ManagerFullname
FROM DimEmployee E1
INNER JOIN DimEmployee E2
	ON E1.EmployeeKey = E2.ParentEmployeeKey

-- 9
SELECT
	FF.Amount,
	A.AccountDescription,
	O.OrganizationName
FROM FactFinance FF
INNER JOIN DimAccount A
	ON FF.AccountKey = A.AccountKey
INNER JOIN DimOrganization O
	ON FF.OrganizationKey = O.OrganizationKey

-- 10
SELECT
	FIS.SalesOrderNumber,
	FIS.SalesAmount,
	P.EnglishProductName,
	PC.EnglishProductCategoryName
FROM FactInternetSales FIS
INNER JOIN DimProduct P
	ON FIS.ProductKey = P.ProductKey
INNER JOIN DimProductSubcategory PS
	ON P.ProductSubcategoryKey = PS.ProductSubcategoryKey
INNER JOIN DimProductCategory PC
	ON PS.ProductCategoryKey = PC.ProductCategoryKey

-- JUST CHALLENGES
-- 1
SELECT
	P.EnglishProductName,
	PS.EnglishProductSubcategoryName
FROM DimProduct P
INNER JOIN DimProductSubcategory PS
	ON P.ProductSubcategoryKey = PS.ProductSubcategoryKey

-- 2
SELECT
	FIS.SalesOrderNumber,
	C.FirstName + ' ' + C.LastName AS FullName,
	G.EnglishCountryRegionName
FROM FactInternetSales FIS
INNER JOIN DimCustomer C
	ON FIS.CustomerKey = C.CustomerKey
INNER JOIN DimGeography G
	ON C.GeographyKey = G.GeographyKey

-- 3
SELECT 
    PS.EnglishProductSubcategoryName,
    P.EnglishProductName
FROM DimProductSubcategory PS
LEFT JOIN DimProduct P
    ON PS.ProductSubcategoryKey = P.ProductSubcategoryKey
WHERE P.ProductKey IS NULL

-- 4
SELECT
	P.EnglishProductName,
	FPI.UnitCost,
	FPI.UnitsBalance
FROM FactProductInventory FPI
INNER JOIN DimProduct P
	ON FPI.ProductKey = P.ProductKey

-- 5
SELECT
	FIS.SalesOrderNumber,
	D1.FullDateAlternateKey AS CalendarOrderDate,
	D2.FullDateAlternateKey AS CalendarShipDate
FROM FactInternetSales FIS
INNER JOIN DimDate D1
	ON FIS.OrderDateKey = D1.DateKey
INNER JOIN DimDate D2
	ON FIS.ShipDateKey = D2.DateKey

-- Second
-- 1
SELECT
	FIS.SalesOrderNumber,
	C.LastName,
	G.EnglishCountryRegionName,
	FIS.SalesAmount
FROM FactInternetSales FIS
INNER JOIN DimCustomer C
	ON FIS.CustomerKey = C.CustomerKey
INNER JOIN DimGeography G
	ON C.GeographyKey = G.GeographyKey
WHERE FIS.SalesAmount > 1000

-- 2

-- MORE CHALLENGES 
-- EASY
-- 1
SELECT
	R.ResellerName,
	G.EnglishCountryRegionName,
	G.City
FROM DimReseller R
INNER JOIN DimGeography G
	ON R.GeographyKey = G.GeographyKey

-- EXEC sp_help 'DimReseller';

-- 2
SELECT
	FIS.SalesOrderNumber,
	FIS.SalesAmount
FROM FactInternetSales FIS
INNER JOIN DimSalesTerritory ST
	ON FIS.SalesTerritoryKey = ST.SalesTerritoryKey
WHERE ST.SalesTerritoryCountry = 'Australia'

-- 3
SELECT * FROM DimProduct
SELECT * FROM DimProductSubcategory
SELECT * FROM DimProduct P
LEFT JOIN DimProductSubcategory PS
	ON P.ProductSubcategoryKey = PS.ProductSubcategoryKey
WHERE PS.ProductSubcategoryKey IS NULL

--MEDIUM
-- 1
SELECT
	DISTINCT R.ResellerName,
	G.City,
	G.EnglishCountryRegionName
FROM FactResellerSales FRS
INNER JOIN DimReseller R
	ON FRS.ResellerKey = R.ResellerKey
INNER JOIN DimGeography G
	ON R.GeographyKey = G.GeographyKey
INNER JOIN DimSalesTerritory ST
	ON FRS.SalesTerritoryKey = ST.SalesTerritoryKey

-- 2
SELECT * FROM FactInternetSales
SELECT * FROM DimDate

