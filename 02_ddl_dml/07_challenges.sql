USE MyDatabase
/******************************************************************************************

1-daraja: Oddiy (Poydevor)
Bu bosqichda siz jadval tuzish va ma'lumot kiritishning asosiy sintaksisini sinab ko'rasiz.

Vazifa: Employees (Xodimlar) deb nomlangan jadval yarating.

Ustunlar: id (integer), name (text), position (text), salary (decimal).

Amallar:

Jadvalga 3 ta xodim ma'lumotini qo'shing.

Xodimlardan birining lavozimini o'zgartiring (UPDATE).

Maoshi eng past xodimni jadvaldan o'chiring (DELETE).

******************************************************************************************/

--0
CREATE TABLE Employee_main (
	id INT PRIMARY KEY,
	firstname VARCHAR(50) NOT NULL,
	position VARCHAR(50) NOT NULL,
	salary DECIMAL(10, 2) NOT NULL
)

SELECT * FROM Employee_main

--1
INSERT INTO Employee_main (id, firstname, position, salary)
VALUES 
	(1, 'Adam', 'Boss', 25000.00),
	(2, 'Alex', 'Manager', 15000.00),
	(3, 'Sarah', 'Engineer', 12000.00)

--2
UPDATE Employee_main 
SET position = 'Product Manager',
	salary = 13500.00
WHERE id = 3 -- We can use firstname but it cannot be professional way

SELECT * FROM Employee_main

--3
DELETE FROM Employee_main
WHERE salary = (SELECT MIN(salary) FROM Employee_main)

SELECT * FROM Employee_main


/******************************************************************************************

2-daraja: O'rta (Mantiqiy cheklovlar)
Bu yerda jadval strukturasini o'zgartirish va ma'lumotlar yaxlitligini ta'minlashga e'tibor qaratamiz.

Vazifa: Avvalgi Employees jadvaliga email degan yangi ustun qo'shing (ALTER).

Amallar:

Barcha mavjud xodimlarning email manzillarini yangilang (masalan, user@company.com formatida).

Jadvalga hire_date (ishga kirgan sana) ustunini qo'shing va standart qiymat (DEFAULT) sifatida bugungi sanani ko'rsating.

Maoshi 5000 dan yuqori bo'lgan barcha xodimlarning lavozimini "Senior" prefiksi bilan yangilang.

******************************************************************************************/

--0
ALTER TABLE Employee_main
ADD email VARCHAR(50)

SELECT * FROM Employee_main

--1
UPDATE Employee_main
SET email = CONCAT(LOWER(LEFT(firstname, 1)), SUBSTRING(firstname, 2, LEN(firstname))) + '@company.com'

SELECT * FROM Employee_main

--2
ALTER TABLE Employee_main
ADD hire_date DATE NOT NULL DEFAULT CURRENT_DATE 
SELECT * FROM Employee_main

--3
UPDATE Employee_main
SET position = CONCAT('Senior', ' ', position)
WHERE salary > 5000

SELECT * FROM Employee_main


/**

3-daraja: Murakkab (Real keys)
Bu topshiriq ma'lumotlar muhandisligi (Data Engineering) jarayonlaridagi real holatga yaqinlashtirilgan.

Ssenariy: Sizda "Smart Fermer" tizimi uchun SensorData jadvali bor. Sizga bu jadvalning strukturasi noto'g'ri loyihalangani va uni o'zgartirish kerakligi aytildi.

Vazifa:

SensorData jadvalini yarating: id, sensor_type, value, recorded_at.

Xatolikni tuzatish: value ustuni string bo'lib qolgan, uni float (yoki decimal) turiga o'zgartirishingiz kerak. (Eslatma: Ba'zi bazalarda turini o'zgartirish uchun ustunni o'chirib qayta qo'shish yoki maxsus USING operatoridan foydalanish talab etilishi mumkin).

Filtrli o'chirish: 2023-yildan eski bo'lgan va value qiymati 0 ga teng bo'lgan barcha "noto'g'ri" ma'lumotlarni birgina so'rov bilan o'chirib tashlang.

*/


--1
CREATE TABLE SensorData (
	id INT PRIMARY KEY,
	sensor_type VARCHAR(50) NOT NULL,
	value VARCHAR(50) NOT NULL,
	recorded_at DATE NOT NULL DEFAULT CURRENT_DATE
)

SELECT * FROM SensorData

--2
-- FIRST WAY
ALTER TABLE SensorData
DROP COLUMN value

ALTER TABLE SensorData
ADD value INT NOT NULL

-- SECOND WAY
ALTER TABLE SensorData
ALTER COLUMN value DECIMAL(10, 2)

--3
INSERT INTO SensorData (id, sensor_type, recorded_at, value)
VALUES 
	(1, 'FingerPrint', '2025-02-22', 111.11),
	(2, 'Code', '2025-02-22', 222.22),
	(3, 'FaceID', '2021-02-22', 444.44),
	(4, 'Code1', '2019-02-22', 0),
	(5, 'Code2', '2020-02-22', 0)

DELETE FROM SensorData
WHERE (recorded_at < '2023-01-01' AND value = 0)

SELECT * FROM SensorData