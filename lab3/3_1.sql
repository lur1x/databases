/* Проверка и создание базы данных */
IF NOT EXISTS (
	SELECT name 
	FROM sys.databases 
	WHERE 
		name = 'cinema_db'
)
BEGIN
    CREATE DATABASE cinema_db;
    PRINT 'База данных cinema_db успешно создана.';
END
ELSE
BEGIN
    PRINT 'База данных cinema_db уже существует.';
END


USE cinema_db;

/* Таблица жанров */
IF NOT EXISTS (
	SELECT 1 
	FROM sys.tables 
	WHERE 
		name = 'genre' 
		AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.genre (
        id_genre INT IDENTITY(1,1) NOT NULL,
        name NVARCHAR(50) NOT NULL,
        description NVARCHAR(500) NULL,
        CONSTRAINT pk_genre PRIMARY KEY (id_genre)
    );
    PRINT 'Таблица genre успешно создана.';
END
ELSE
BEGIN
    PRINT 'Таблица genre уже существует.';
END


/* Таблица фильмов */
IF NOT EXISTS (
	SELECT 1 
	FROM sys.tables 
	WHERE 
		name = 'movie' 
		AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.movie (
        id_movie INT IDENTITY(1,1) NOT NULL,
        title NVARCHAR(100) NOT NULL,
        duration INT NOT NULL,
        release_date DATE NOT NULL,
        age_rating NVARCHAR(10) NOT NULL,
        description NVARCHAR(MAX) NULL,
        id_genre INT NULL,
        CONSTRAINT pk_movie PRIMARY KEY (id_movie),
        CONSTRAINT fk_movie_genre FOREIGN KEY (id_genre) REFERENCES dbo.genre(id_genre)
    );
    PRINT 'Таблица movie успешно создана.';
END
ELSE
BEGIN
    PRINT 'Таблица movie уже существует.';
END


/* Таблица кинотеатров */
IF NOT EXISTS (
	SELECT 1 
	FROM sys.tables 
	WHERE 
		name = 'cinema' 
		AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.cinema (
        id_cinema INT IDENTITY(1,1) NOT NULL,
        name NVARCHAR(100) NOT NULL,
        address NVARCHAR(200) NOT NULL,
        phone NVARCHAR(20) NULL,
        opening_time TIME NOT NULL,
        closing_time TIME NOT NULL,
        CONSTRAINT pk_cinema PRIMARY KEY (id_cinema)
    );
    PRINT 'Таблица cinema успешно создана.';
END
ELSE
BEGIN
    PRINT 'Таблица cinema уже существует.';
END


/* Таблица залов */
IF NOT EXISTS (SELECT 1 
	FROM sys.tables 
	WHERE 
		name = 'hall' 
		AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.hall (
        id_hall INT IDENTITY(1,1) NOT NULL,
        name NVARCHAR(50) NOT NULL,
        capacity INT NOT NULL,
        id_cinema INT NOT NULL,
        has_3d TINYINT NOT NULL DEFAULT 0,
        has_dolby TINYINT NOT NULL DEFAULT 0,
        CONSTRAINT pk_hall PRIMARY KEY (id_hall),
        CONSTRAINT fk_hall_cinema FOREIGN KEY (id_cinema) REFERENCES dbo.cinema(id_cinema)
    );
    PRINT 'Таблица hall успешно создана.';
END
ELSE
BEGIN
    PRINT 'Таблица hall уже существует.';
END


/* Таблица сеансов */
IF NOT EXISTS (
	SELECT 1 
	FROM sys.tables 
	WHERE 
		name = 'screening' 
		AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.screening (
        id_screening INT IDENTITY(1,1) NOT NULL,
        start_time DATETIME2 NOT NULL,
        id_movie INT NOT NULL,
        id_hall INT NOT NULL,
        is_premiere TINYINT NOT NULL DEFAULT 0,
        CONSTRAINT pk_screening PRIMARY KEY (id_screening),
        CONSTRAINT fk_screening_movie FOREIGN KEY (id_movie) REFERENCES dbo.movie(id_movie),
        CONSTRAINT fk_screening_hall FOREIGN KEY (id_hall) REFERENCES dbo.hall(id_hall)
    );
    PRINT 'Таблица screening успешно создана.';
END
ELSE
BEGIN
    PRINT 'Таблица screening уже существует.';
END


/* Таблица состава фильма */
IF NOT EXISTS (
	SELECT 1 
	FROM sys.tables 
	WHERE 
		name = 'person' 
		AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.person (
        id_person INT IDENTITY(1,1) NOT NULL,
        first_name NVARCHAR(50) NOT NULL,
        last_name NVARCHAR(50) NOT NULL,
        birth_date DATE NULL,
        biography NVARCHAR(MAX) NULL,
        CONSTRAINT pk_person PRIMARY KEY (id_person)
    );
    PRINT 'Таблица person успешно создана.';
END
ELSE
BEGIN
    PRINT 'Таблица person уже существует.';
END


/* Таблица связи фильмов и людей */
IF NOT EXISTS (
	SELECT 1 
	FROM sys.tables 
	WHERE 
		name = 'movie_person' 
		AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.movie_person (
        id_movie_person INT IDENTITY(1,1) NOT NULL,
        id_movie INT NOT NULL,
        id_person INT NOT NULL,
        role_type NVARCHAR(30) NOT NULL,
        role_name NVARCHAR(100) NULL,
        CONSTRAINT pk_movie_person PRIMARY KEY (id_movie_person),
        CONSTRAINT fk_movie_person_movie FOREIGN KEY (id_movie) REFERENCES dbo.movie(id_movie),
        CONSTRAINT fk_movie_person_person FOREIGN KEY (id_person) REFERENCES dbo.person(id_person)
    );
    PRINT 'Таблица movie_person успешно создана.';
END
ELSE
BEGIN
    PRINT 'Таблица movie_person уже существует.';
END


/* Таблица покупателей */
IF NOT EXISTS (
	SELECT 1 
	FROM sys.tables 
	WHERE 
		name = 'customer' 
		AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.customer (
        id_customer INT IDENTITY(1,1) NOT NULL,
        first_name NVARCHAR(50) NOT NULL,
        last_name NVARCHAR(50) NOT NULL,
        email NVARCHAR(100) NULL,
        phone NVARCHAR(20) NULL,
        registration_date DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_customer PRIMARY KEY (id_customer)
    );
    PRINT 'Таблица customer успешно создана.';
END
ELSE
BEGIN
    PRINT 'Таблица customer уже существует.';
END


/* Таблица цен */
IF NOT EXISTS (
	SELECT 1 
	FROM sys.tables 
	WHERE
		name = 'price' 
		AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.price (
        id_price INT IDENTITY(1,1) NOT NULL,
        name NVARCHAR(50) NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        description NVARCHAR(200) NULL,
        CONSTRAINT pk_price PRIMARY KEY (id_price)
    );
    PRINT 'Таблица price успешно создана.';
END
ELSE
BEGIN
    PRINT 'Таблица price уже существует.';
END


/* Таблица билетов */
IF NOT EXISTS (
	SELECT 1 
	FROM sys.tables 
	WHERE 
		name = 'ticket' 
		AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE dbo.ticket (
        id_ticket INT IDENTITY(1,1) NOT NULL,
        id_screening INT NOT NULL,
        id_customer INT NOT NULL,
        id_price INT NOT NULL,
        seat_number NVARCHAR(10) NOT NULL,
        purchase_date DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT pk_ticket PRIMARY KEY (id_ticket),
        CONSTRAINT fk_ticket_screening FOREIGN KEY (id_screening) REFERENCES dbo.screening(id_screening),
        CONSTRAINT fk_ticket_customer FOREIGN KEY (id_customer) REFERENCES dbo.customer(id_customer),
        CONSTRAINT fk_ticket_price FOREIGN KEY (id_price) REFERENCES dbo.price(id_price)
    );
    PRINT 'Таблица ticket успешно создана.';
END
ELSE
BEGIN
    PRINT 'Таблица ticket уже существует.';
END


PRINT 'Все объекты базы данных cinema_db успешно проверены/созданы.';


SELECT 
    name AS table_name,
    SCHEMA_NAME(schema_id) AS schema_name
FROM sys.tables
ORDER BY schema_name, table_name;


/* Жанры */
SELECT * FROM dbo.genre;

/* Фильмы */
SELECT * FROM dbo.movie;

/* Кинотеатры */
SELECT * FROM dbo.cinema;

/* Залы */
SELECT * FROM dbo.hall;

/* Сеансы */
SELECT * FROM dbo.screening;

/* Люди (актёры, режиссёры) */
SELECT * FROM dbo.person;

/* Связь фильмов и людей */
SELECT * FROM dbo.movie_person;

/* Покупатели */
SELECT * FROM dbo.customer;

/* Цены */
SELECT * FROM dbo.price;

/* Билеты */
SELECT * FROM dbo.ticket;


/* изменение типа данных */
USE cinema_db
ALTER TABLE dbo.hall
ALTER COLUMN has_3d TINYINT NOT NULL;

ALTER TABLE dbo.hall
ALTER COLUMN has_dolby TINYINT NOT NULL;


