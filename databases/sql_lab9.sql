﻿use UNIVER;

--1.	Создать пакет, реализующий следующие действия:
--a) проверить существование таблицы Сырье_1,
--b) если такая таблица существует, удалить ее из базы данных,
--c) создать копию таблицы Сырье под именем Сырье_1,
--d) вывести данные таблицы Сырье_1, относящиеся к типам сырья Посуда и Прочие,
--e) изменить в таблице  «Сырье_1» тип сырья Посуда на тип сырья  Прочие,
--f) вывести данные таблицы Сырье_1, относящиеся к типам сырья Посуда и Прочие.

DROP TABLE IF EXISTS Сырье_копия;

SELECT * INTO Сырье_копия FROM dbo.Сырье;

SELECT 
	s1.НаимСырья,
	ts.НаимТипаСырья
FROM Сырье_копия as s1
JOIN dbo.Типы_сырья AS ts ON ts.КодТипаСырья = s1.КодТипаСырья 
where ts.НаимТипаСырья in ('Посуда','Прочие')
ORDER BY s1.НаимСырья;

DECLARE @КодПосуды int;
SET @КодПосуды  = (SELECT КодТипаСырья FROM dbo.Типы_сырья WHERE НаимТипаСырья = 'Посуда'); 

DECLARE @КодПрочие int;
SET @КодПрочие = (SELECT КодТипаСырья FROM dbo.Типы_сырья WHERE НаимТипаСырья = 'Прочие');

UPDATE  dbo.Сырье_копия SET КодТипаСырья = @КодПрочие WHERE КодТипаСырья = @КодПосуды;

SELECT 
	s1.НаимСырья,
	ts.НаимТипаСырья
FROM Сырье_копия as s1
JOIN dbo.Типы_сырья AS ts ON ts.КодТипаСырья = s1.КодТипаСырья 
where ts.НаимТипаСырья in ('Посуда','Прочие')
ORDER BY s1.НаимСырья
GO

--2.	Создать пакет, реализующий следующие действия:
--a) 1a,
--b) 1b,
--c) 1c,
--d) вывести данные о средней цене продуктов и средней цене напитков
--e) Если средняя цена продуктов больше средней цены напитков, то уменьшая на каждом шаге цикла цену всех
--продуктов на 20%, определить количество шагов, необходимых для достижения ситуации, 
--когда средняя цена продуктов не превышает среднюю цену напитков. 
--Если средняя цена напитков, больше средней цены продуктов, то уменьшая на каждом шаге цикла цену всех 
--напитков на 20%, определить количество шагов, необходимых для достижения ситуации, 
--когда средняя цена продуктов превышает среднюю цену напитков. 
--f) вывести данные о средней цене продуктов, средней цене напитков и количестве шагов цикла

DROP FUNCTION IF EXISTS fn_CalculateAvgPrice;
GO
CREATE FUNCTION fn_CalculateAvgPrice ( @type nvarchar(50))
RETURNS real
AS
BEGIN
DECLARE @avgPrice real;
	SET @avgPrice = 
		(SELECT 
			AVG(sc.ЦенаСырья)
		FROM dbo.Сырье_копия as sc 
		JOIN dbo.Типы_сырья AS ts ON ts.КодТипаСырья = sc.КодТипаСырья 
		where ts.НаимТипаСырья = @type)
	RETURN @avgPrice
END;
GO

DROP TABLE IF EXISTS Сырье_копия;

SELECT * INTO Сырье_копия FROM dbo.Сырье;

SELECT 
	ts.НаимТипаСырья as 'Тип сырья',
	AVG(sc.ЦенаСырья) as 'Средняя цена'
FROM dbo.Сырье_копия as sc 
JOIN dbo.Типы_сырья AS ts ON ts.КодТипаСырья = sc.КодТипаСырья 
where ts.НаимТипаСырья in ('Продукты','Напитки')
GROUP BY ts.НаимТипаСырья;


DECLARE @КодПродуктов int;
	SET @КодПродуктов= (SELECT КодТипаСырья FROM dbo.Типы_сырья WHERE НаимТипаСырья = 'Продукты'); 
DECLARE @КодНапитков int;
	SET @КодНапитков = (SELECT КодТипаСырья FROM dbo.Типы_сырья WHERE НаимТипаСырья = 'Напитки');
DECLARE @iterator int;
	SET @iterator = 0;

IF dbo.fn_CalculateAvgPrice('Напитки') > dbo.fn_CalculateAvgPrice('Продукты')
	WHILE dbo.fn_CalculateAvgPrice('Напитки') >= dbo.fn_CalculateAvgPrice('Продукты')
	BEGIN
		UPDATE dbo.Сырье_копия SET ЦенаСырья = ЦенаСырья*0.8 WHERE КодТипаСырья = @КодНапитков
		SET @iterator = @iterator + 1
	END
ELSE IF dbo.fn_CalculateAvgPrice('Продукты') > dbo.fn_CalculateAvgPrice('Напитки')
	WHILE dbo.fn_CalculateAvgPrice('Продукты') >= dbo.fn_CalculateAvgPrice('Напитки')
	BEGIN
		UPDATE dbo.Сырье_копия SET ЦенаСырья = ЦенаСырья*0.8 WHERE КодТипаСырья = @КодПродуктов
		SET @iterator = @iterator + 1
	END

SELECT 
	ts.НаимТипаСырья as 'Тип сырья',
	AVG(sc.ЦенаСырья) as 'Средняя цена',
	@iterator as 'Количество итераций'
FROM dbo.Сырье_копия as sc 
JOIN dbo.Типы_сырья AS ts ON ts.КодТипаСырья = sc.КодТипаСырья 
where ts.НаимТипаСырья in ('Продукты','Напитки')
GROUP BY ts.НаимТипаСырья;

GO