
USE warehouse_db;

/* 3.1 INSERT */

/* 3.1.a Вставка без указания списка полей (в таблицу unit) */
INSERT INTO dbo.unit VALUES 
('Штука', 'шт'),
('Килограмм', 'кг'),
('Литр', 'л');
PRINT 'Добавлены основные единицы измерения';

/* 3.1.b Вставка с указанием списка полей (в таблицу product) */
INSERT INTO dbo.product (name, description, id_unit, current_price, barcode)
VALUES 
('Молоко 2,5%', 'Молоко пастеризованное', 1, 89.90, '4601234567890'),
('Хлеб Бородинский', 'Хлеб ржаной', 1, 45.50, '4609876543210'),
('Яблоки Голден', 'Яблоки свежие', 2, 129.90, '4605555555555');
PRINT 'Добавлены основные товары';

/* 3.1.c Вставка с чтением из другой таблицы (создадим архивную таблицу сначала) */
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'product_archive')
BEGIN
    CREATE TABLE dbo.product_archive (
        id_product INT NOT NULL,
        name NVARCHAR(100) NOT NULL,
        id_unit INT NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        archive_date DATETIME DEFAULT GETDATE()
    );
    PRINT 'Создана таблица product_archive';
END

/* Теперь выполняем вставку из product в product_archive */
INSERT INTO dbo.product_archive (id_product, name, id_unit, price)
SELECT id_product, name, id_unit, current_price 
FROM dbo.product 
WHERE current_price > 100;
PRINT 'Дорогие товары скопированы в архив';

/* 3.2 DELETE */

/* Создадим временную таблицу для демонстрации */
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'temp_products')
BEGIN
    SELECT * INTO dbo.temp_products FROM dbo.product WHERE 1=0;
    PRINT 'Создана временная таблица temp_products';
END

/* 3.2.a Удаление всех записей (очистка временной таблицы) */
DELETE FROM dbo.temp_products;
PRINT 'Временная таблица товаров очищена';

/* 3.2.b Удаление по условию (товары без штрих-кода) */
Добавим тестовый товар без штрих-кода
INSERT INTO dbo.product (name, id_unit, current_price) 
VALUES ('Тестовый товар', 1, 10.00);

DELETE FROM dbo.product 
WHERE barcode IS NULL;
PRINT 'Удалены товары без штрих-кода';

/* 3.3 UPDATE */

/* 3.3.a Обновление всех записей (повышение цен на 5%) */
UPDATE dbo.product 
SET current_price = current_price * 1.05;
PRINT 'Цены на все товары повышены на 5%';

/* 3.3.b Обновление одного атрибута по условию (изменение описания) */
UPDATE dbo.product 
SET description = 'Молоко ультрапастеризованное' 
WHERE name LIKE '%Молоко%';
PRINT 'Обновлено описание молочных товаров';

/* 3.3.c Обновление нескольких атрибутов по условию (изменение цены и штрих-кода) */
UPDATE dbo.product 
SET 
    current_price = 99.90,
    barcode = '4601111111111'
WHERE name = 'Молоко 2,5%';
PRINT 'Обновлены данные по молоку';

/* 3.4 SELECT */

/* 3.4.a Выборка конкретных атрибутов (название и цена товаров) */
SELECT name, current_price 
FROM dbo.product;
PRINT 'Получен список товаров с ценами';

/* 3.4.b Выборка всех атрибутов (все данные о товарах) */
SELECT * 
FROM dbo.product;
PRINT 'Получены все данные о товарах';

/* 3.4.c Выборка с условием (дорогие товары) */
SELECT * 
FROM dbo.product 
WHERE current_price > 100;
PRINT 'Получен список дорогих товаров';

/* 3.5 SELECT ORDER BY + TOP */

/* 3.5.a Сортировка по возрастанию с ограничением (5 самых дешевых товаров) */
SELECT TOP 5 name, current_price 
FROM dbo.product 
ORDER BY current_price ASC;
PRINT 'Получены 5 самых дешевых товаров';

/* 3.5.b Сортировка по убыванию (самые дорогие товары) */
SELECT name, current_price 
FROM dbo.product 
ORDER BY current_price DESC;
PRINT 'Получены товары отсортированные по убыванию цены';

/* 3.5.c Сортировка по двум атрибутам (по единице измерения и цене) */
SELECT TOP 10 name, id_unit, current_price 
FROM dbo.product 
ORDER BY id_unit, current_price DESC;
PRINT 'Получены топ-10 товаров по категориям и цене';

/* 3.5.d Сортировка по первому атрибуту (по названию) */
SELECT name, current_price 
FROM dbo.product 
ORDER BY 1;
PRINT 'Товары отсортированы по названию';

/* 3.6 Работа с датами */

/* Добавим тестовые данные в invoice для демонстрации */
INSERT INTO dbo.warehouse (name, address) VALUES ('Основной склад', 'ул. Складская, 1');
INSERT INTO dbo.supplier (name, phone) VALUES ('ООО Поставщик', '+79991234567');
INSERT INTO dbo.employee (first_name, last_name, position, hire_date) 
VALUES ('Иван', 'Иванов', 'Кладовщик', '2020-01-15');

INSERT INTO dbo.invoice (invoice_number, invoice_date, id_supplier, id_warehouse, id_employee, total_amount)
VALUES 
('INV-0001', '2023-11-15', 1, 1, 1, 1000.00),
('INV-0002', '2023-11-20', 1, 1, 1, 1500.00),
('INV-0003', '2022-05-10', 1, 1, 1, 800.00);

/* 3.6.a WHERE по дате (накладные за конкретный день) */
SELECT * 
FROM dbo.invoice 
WHERE invoice_date = '2023-11-15';
PRINT 'Накладные за 15 ноября 2023';

/* 3.6.b WHERE дата в диапазоне (накладные за последнюю неделю) */
SELECT * 
FROM dbo.invoice 
WHERE invoice_date BETWEEN DATEADD(day, -7, GETDATE()) AND GETDATE();
PRINT 'Накладные за последнюю неделю';

/* 3.6.c Извлечение года из даты (статистика по годам) */
SELECT YEAR(invoice_date) AS year, COUNT(*) AS invoice_count 
FROM dbo.invoice 
GROUP BY YEAR(invoice_date);
PRINT 'Количество накладных по годам';

/* 3.7 Функции агрегации */

/* 3.7.a Количество записей (всего товаров) */
SELECT COUNT(*) AS total_products 
FROM dbo.product;
PRINT 'Общее количество товаров';

/* 3.7.b Количество уникальных записей (уникальных единиц измерения) */
SELECT COUNT(DISTINCT id_unit) AS unique_units 
FROM dbo.product;
PRINT 'Количество используемых единиц измерения';

/* 3.7.c Уникальные значения (все используемые единицы измерения) */
SELECT DISTINCT id_unit 
FROM dbo.product;
PRINT 'Список используемых единиц измерения';

/* 3.7.d Максимальное значение (максимальная цена) */
SELECT MAX(current_price) AS max_price 
FROM dbo.product;
PRINT 'Максимальная цена товара';

/* 3.7.e Минимальное значение (минимальная цена) */
SELECT MIN(current_price) AS min_price 
FROM dbo.product;
PRINT 'Минимальная цена товара';

/* 3.7.f COUNT + GROUP BY (количество товаров по категориям) */
SELECT id_unit, COUNT(*) AS product_count 
FROM dbo.product 
GROUP BY id_unit;
PRINT 'Количество товаров по единицам измерения';

/* 3.8 SELECT GROUP BY + HAVING */

/* Добавим тестовые данные в invoice_product */
INSERT INTO dbo.invoice_product (id_invoice, id_product, quantity, unit_price, total_price)
VALUES 
(1, 1, 10, 89.90, 899.00),
(1, 2, 5, 45.50, 227.50),
(2, 3, 8, 129.90, 1039.20),
(3, 1, 3, 89.90, 269.70);

/* 3.8.a Категории товаров с средней ценой выше 100 руб */
SELECT 
    id_unit, 
    AVG(current_price) AS avg_price
FROM dbo.product
GROUP BY id_unit
HAVING AVG(current_price) > 100;
PRINT 'Категории товаров со средней ценой выше 100 руб';

/* 3.8.b Поставщики с более чем 1 накладной (изменим условие, так как данных мало) */
SELECT 
    id_supplier, 
    COUNT(*) AS invoice_count
FROM dbo.invoice
GROUP BY id_supplier
HAVING COUNT(*) > 1;
PRINT 'Поставщики с более чем 1 накладной';

/* 3.8.c Товары, которые заказывались более 1 раза (изменим условие) */
SELECT 
    id_product, 
    SUM(quantity) AS total_quantity
FROM dbo.invoice_product
GROUP BY id_product
HAVING SUM(quantity) > 1;
PRINT 'Товары с общим количеством заказов более 1';

/* 3.9 SELECT JOIN */

/* 3.9.a LEFT JOIN + WHERE (товары с их единицами измерения) */
SELECT 
    p.name AS product_name,
    u.name AS unit_name
FROM dbo.product p
LEFT JOIN dbo.unit u ON p.id_unit = u.id_unit
WHERE p.current_price > 50;
PRINT 'Товары дороже 50 руб с единицами измерения';

/* 3.9.b RIGHT JOIN (аналогично предыдущему, но через RIGHT JOIN) */
SELECT 
    p.name AS product_name,
    u.name AS unit_name
FROM dbo.unit u
RIGHT JOIN dbo.product p ON u.id_unit = p.id_unit
WHERE p.current_price > 50;
PRINT 'Товары дороже 50 руб (через RIGHT JOIN)';

/* 3.9.c LEFT JOIN трех таблиц (накладные с товарами и поставщиками) */
SELECT 
    i.invoice_number,
    s.name AS supplier_name,
    p.name AS product_name,
    ip.quantity
FROM dbo.invoice i
LEFT JOIN dbo.supplier s ON i.id_supplier = s.id_supplier
LEFT JOIN dbo.invoice_product ip ON i.id_invoice = ip.id_invoice
LEFT JOIN dbo.product p ON ip.id_product = p.id_product
WHERE 
    i.invoice_date > '2022-01-01'
    AND s.phone IS NOT NULL
    AND p.current_price > 20;
PRINT 'Накладные с фильтрами по дате, поставщикам и товарам';

/* 3.9.d INNER JOIN (товары в накладных) */
SELECT 
    i.invoice_number,
    p.name AS product_name,
    ip.quantity,
    ip.unit_price
FROM dbo.invoice_product ip
INNER JOIN dbo.product p ON ip.id_product = p.id_product
INNER JOIN dbo.invoice i ON ip.id_invoice = i.id_invoice;
PRINT 'Товары в накладных';

/* 3.10 Подзапросы */

/* 3.10.a WHERE IN (товары, которые есть в накладных) */
SELECT * 
FROM dbo.product
WHERE id_product IN (
    SELECT DISTINCT id_product 
    FROM dbo.invoice_product
);
PRINT 'Товары, которые есть в накладных';

/* 3.10.b SELECT подзапрос (товары с информацией о количестве продаж) */
SELECT 
    p.name,
    p.current_price,
    (SELECT SUM(quantity) 
     FROM dbo.invoice_product ip 
     WHERE ip.id_product = p.id_product) AS total_sold
FROM dbo.product p;
PRINT 'Товары с информацией о количестве продаж';

/* 3.10.c FROM подзапрос (топ-2 самых продаваемых товаров) */
SELECT * FROM (
    SELECT 
        p.name,
        SUM(ip.quantity) AS total_quantity,
        RANK() OVER (ORDER BY SUM(ip.quantity) DESC) AS rank
    FROM dbo.product p
    JOIN dbo.invoice_product ip ON p.id_product = ip.id_product
    GROUP BY p.name
) AS ranked_products
WHERE rank <= 2;
PRINT 'Топ-2 самых продаваемых товаров';

/* 3.10.d JOIN подзапрос (поставщики с количеством накладных) */
SELECT 
    s.name,
    s.phone,
    inv.invoice_count
FROM dbo.supplier s
JOIN (
    SELECT 
        id_supplier, 
        COUNT(*) AS invoice_count
    FROM dbo.invoice
    GROUP BY id_supplier
) AS inv ON s.id_supplier = inv.id_supplier;
PRINT 'Поставщики с количеством накладных';

PRINT 'Все запросы выполнены успешно';