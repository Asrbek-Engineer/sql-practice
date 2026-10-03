/*
  Topic: String functions - CONCAT, UPPER/LOWER, TRIM, REPLACE
  Use case: cleaning raw contact data (staging layer)
*/

USE UnionPractice;

CREATE TABLE raw_contacts (id INT, full_name VARCHAR(50), phone VARCHAR(20), city VARCHAR(20));
INSERT INTO raw_contacts VALUES
(1, '  ali valiyev ', '+998-90-123-45-67', 'tashkent'),
(2, 'ANNA SMITH', '+998 91 555 22 11', '  Samarkand'),
(3, 'Vali  ', '998-93-000-11-22', 'BUKHARA ');

-- Task 1: Remove leading and trailing spaces from names and cities.
SELECT
	TRIM(full_name) AS full_name_trim, TRIM(city) AS city_trim
FROM raw_contacts;

-- Task 2: Standardize city names: no extra spaces, uppercase.
SELECT
	UPPER(TRIM(city)) AS city_trim_upper
FROM raw_contacts;

-- Task 3: Remove dashes and spaces from phone numbers.
SELECT
	REPLACE(REPLACE(phone, '-', ''), ' ', '') AS clean_phone
FROM raw_contacts;

-- Task 4: Build a "Name - CITY" label.
SELECT
	CONCAT(TRIM(full_name), ' - ', UPPER(TRIM(city))) AS result
FROM raw_contacts;

-- Task 5: Create a normalized name key (trimmed, lowercase) for matching.
-- SQL Server compares strings case-insensitively by default,
-- but other databases (e.g. PostgreSQL) do not, so LOWER keeps matching portable.
SELECT
	LOWER(TRIM(full_name)) AS clean_name
FROM raw_contacts;


-- Final: all cleaning steps combined in one staging query.
SELECT
	id,
	TRIM(full_name) AS full_name,
	REPLACE(REPLACE(phone, '-', ''), ' ', '') AS phone,
	UPPER(TRIM(city)) AS city,
	LOWER(TRIM(full_name)) AS name_key
FROM raw_contacts;