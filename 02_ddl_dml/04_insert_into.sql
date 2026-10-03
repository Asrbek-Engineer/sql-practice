USE MyDatabase

-- Rules: Matching Data Types, Column Count & Constraints

-- Note: Columns not included in INSERT become NULL(unless a default or constraint exists)


SELECT * FROM customers

INSERT INTO customers (id, first_name, country, score)
VALUES
	(6, 'Anna', 'USA', NULL),
	(7, 'Sam', NULL, 100)


SELECT * FROM customers




-- INSERT DATA USING ANOTHER TABLE

-- Copy data from 'customers' table into 'persons'
INSERT INTO persons (id, person_name, birth_date, phone)
SELECT id, first_name, NULL, 'Unknown'
FROM customers

 