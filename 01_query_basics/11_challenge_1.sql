USE AdventureWorksDW2025


------------------------------------------LEVEL_1------------------------------------------
-- 1. DimProduct jadvalidan barcha mahsulot nomlarini alifbo bo‘yicha tartibla.
SELECT *
FROM DimProduct
ORDER BY EnglishProductName ASC


-- 2. DimCustomer jadvalidan 30 yoshdan katta customer’larni chiqar.
SELECT
	c.CustomerKey, c.FirstName, c.LastName, c.BirthDate, GETDATE() AS Today, (YEAR(GETDATE()) - YEAR(c.BirthDate)) AS AGE
FROM DimCustomer c
WHERE (YEAR(GETDATE()) - YEAR(c.BirthDate)) > 30
ORDER BY AGE


-- 3. DimProduct jadvalidan mavjud bo‘lgan ranglarning takrorlanmaydigan ro‘yxatini chiqar.
SELECT DISTINCT dp.Color
FROM DimProduct dp


------------------------------------------LEVEL_2------------------------------------------
-- 4. FactInternetSales jadvalidan har bir salesorder uchun umumiy quantity miqdorini hisobla.
SELECT FIS.SalesOrderNumber, SUM(FIS.OrderQuantity) AS TotalQuantity
FROM FactInternetSales FIS
GROUP BY FIS.SalesOrderNumber


-- 5. FactInternetSales jadvalidan faqat 100 dollardan kichik bo‘lmagan (≥100) sales amount’larni chiqar va ularni SalesAmount bo‘yicha kamayish tartibida tartibla.
SELECT SalesAmount
FROM FactInternetSales
WHERE SalesAmount >= 100
ORDER BY SalesAmount DESC


-- 6. DimProduct jadvalidan ListPrice > 1000 bo‘lgan premium mahsulotlarni chiqar va ListPrice bo‘yicha tartibla.
SELECT EnglishProductName, ListPrice
FROM DimProduct
WHERE ListPrice > 1000
ORDER BY ListPrice ASC


-- 7. DimProduct jadvalidan har bir rang (Color) bo‘yicha o‘rtacha ListPrice’ni hisobla.
SELECT Color, AVG(ListPrice)
FROM DimProduct
GROUP BY Color


------------------------------------------LEVEL_3------------------------------------------
-- 8. FactInternetSales jadvalidan eng katta SalesAmount qiymatiga ega yozuvni top.
SELECT TOP 1 *
FROM FactInternetSales
ORDER BY SalesAmount DESC


-- 9. FactInternetSales jadvalida har bir SalesOrderNumber bo‘yicha nechta qator borligini hisobla va faqat 5 tadan ko‘p yozuvga ega buyurtmalarni chiqar.
SELECT SalesOrderNumber, COUNT(SalesOrderNumber)
FROM FactInternetSales
GROUP BY SalesOrderNumber
HAVING COUNT(SalesOrderNumber) > 5


-- 10. DimProduct jadvalidan eng qimmat 5 ta mahsulotni chiqar.
SELECT TOP 5 *
FROM DimProduct
ORDER BY ListPrice DESC