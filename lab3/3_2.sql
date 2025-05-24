/* Проверяем и создаем базу данных */
IF NOT EXISTS (
	SELECT name 
	FROM sys.databases 
	WHERE 
		name = 'warehouse_db'
)
BEGIN
    CREATE DATABASE warehouse_db;
    PRINT 'База данных warehouse_db успешно создана.';
END
ELSE
BEGIN
    PRINT 'База данных warehouse_db уже существует.';
END


USE warehouse_db;


/* 1. Таблица единиц измерения */
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE 
        name = 'unit' 
        AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.unit (
        id_unit INT IDENTITY(1,1) NOT NULL,
        name NVARCHAR(50) NOT NULL,
        abbreviation NVARCHAR(10) NULL,
        CONSTRAINT pk_unit PRIMARY KEY (id_unit)
    );
    PRINT 'Таблица unit успешно создана';
END
ELSE
BEGIN
    PRINT 'Таблица unit уже существует';
END


/* 2. Таблица товаров */
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE 
        name = 'product' 
        AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.product (
        id_product INT IDENTITY(1,1) NOT NULL,
        name NVARCHAR(100) NOT NULL,
        description NVARCHAR(500) NULL,
        id_unit INT NOT NULL,
        current_price DECIMAL(10,2) NOT NULL,
        barcode NVARCHAR(50) NULL,
        CONSTRAINT pk_product PRIMARY KEY (id_product),
        CONSTRAINT fk_product_unit FOREIGN KEY (id_unit) REFERENCES unit(id_unit)
    );
    PRINT 'Таблица product успешно создана';
END
ELSE
BEGIN
    PRINT 'Таблица product уже существует';
END


/* 3. Таблица складов */
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE 
        name = 'warehouse' 
        AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.warehouse (
        id_warehouse INT IDENTITY(1,1) NOT NULL,
        name NVARCHAR(100) NOT NULL,
        address NVARCHAR(200) NOT NULL,
        capacity INT NULL,
        CONSTRAINT pk_warehouse PRIMARY KEY (id_warehouse)
    );
    PRINT 'Таблица warehouse успешно создана';
END
ELSE
BEGIN
    PRINT 'Таблица warehouse уже существует';
END


/* 4. Таблица поставщиков */
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE 
        name = 'supplier' 
        AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.supplier (
        id_supplier INT IDENTITY(1,1) NOT NULL,
        name NVARCHAR(100) NOT NULL,
        contact_person NVARCHAR(100) NULL,
        phone NVARCHAR(20) NOT NULL,
        email NVARCHAR(100) NULL,
        CONSTRAINT pk_supplier PRIMARY KEY (id_supplier)
    );
    PRINT 'Таблица supplier успешно создана';
END
ELSE
BEGIN
    PRINT 'Таблица supplier уже существует';
END


/* 5. Таблица сотрудников */
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE 
        name = 'employee' 
        AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.employee (
        id_employee INT IDENTITY(1,1) NOT NULL,
        first_name NVARCHAR(50) NOT NULL,
        last_name NVARCHAR(50) NOT NULL,
        position NVARCHAR(50) NOT NULL,
        hire_date DATE NOT NULL,
        CONSTRAINT pk_employee PRIMARY KEY (id_employee)
    );
    PRINT 'Таблица employee успешно создана';
END
ELSE
BEGIN
    PRINT 'Таблица employee уже существует';
END


/* 6. Таблица накладных */
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE 
        name = 'invoice' 
        AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.invoice (
        id_invoice INT IDENTITY(1,1) NOT NULL,
        invoice_number NVARCHAR(20) NOT NULL,
        invoice_date DATE NOT NULL DEFAULT GETDATE(),
        id_supplier INT NOT NULL,
        id_warehouse INT NOT NULL,
        id_employee INT NOT NULL,
        total_amount DECIMAL(12,2) NOT NULL,
        notes NVARCHAR(500) NULL,
        CONSTRAINT pk_invoice PRIMARY KEY (id_invoice),
        CONSTRAINT fk_invoice_supplier FOREIGN KEY (id_supplier) REFERENCES supplier(id_supplier),
        CONSTRAINT fk_invoice_warehouse FOREIGN KEY (id_warehouse) REFERENCES warehouse(id_warehouse),
        CONSTRAINT fk_invoice_employee FOREIGN KEY (id_employee) REFERENCES employee(id_employee)
    );
    PRINT 'Таблица invoice успешно создана';
END
ELSE
BEGIN
    PRINT 'Таблица invoice уже существует';
END

/* 7. Таблица товаров в накладных */
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables 
    WHERE 
        name = 'invoice_product' 
        AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.invoice_product (
        id_invoice_product INT IDENTITY(1,1) NOT NULL,
        id_invoice INT NOT NULL,
        id_product INT NOT NULL,
        quantity DECIMAL(10,3) NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        total_price DECIMAL(12,2) NOT NULL,
        CONSTRAINT pk_invoice_product PRIMARY KEY (id_invoice_product),
        CONSTRAINT fk_invoice_product_invoice FOREIGN KEY (id_invoice) REFERENCES invoice(id_invoice),
        CONSTRAINT fk_invoice_product_product FOREIGN KEY (id_product) REFERENCES product(id_product)
    );
    PRINT 'Таблица invoice_product успешно создана';
END
ELSE
BEGIN
    PRINT 'Таблица invoice_product уже существует';
END

PRINT 'Все таблицы и индексы успешно созданы/проверены';