-- Создание базы данных
CREATE DATABASE CinemaDB;
GO

USE CinemaDB;
GO

-- Таблица кинотеатров
CREATE TABLE Cinema (
    CinemaID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200) NOT NULL,
    PhoneNumber NVARCHAR(20),
    OpeningTime TIME,
    ClosingTime TIME,
    TotalHalls INT DEFAULT 1,
    IsActive BIT DEFAULT 1
);

-- Таблица залов кинотеатра
CREATE TABLE CinemaHall (
    HallID INT PRIMARY KEY IDENTITY(1,1),
    CinemaID INT NOT NULL,
    HallNumber INT NOT NULL,
    Capacity INT NOT NULL,
    ScreenType NVARCHAR(50) DEFAULT 'Standard',
    Has3D BIT DEFAULT 0,
    CONSTRAINT FK_CinemaHall_Cinema FOREIGN KEY (CinemaID) REFERENCES Cinema(CinemaID),
    CONSTRAINT UQ_CinemaHall_Number UNIQUE (CinemaID, HallNumber)
);

-- Таблица фильмов
CREATE TABLE Movie (
    MovieID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100) NOT NULL,
    ReleaseYear INT,
    Duration INT NOT NULL, -- в минутах
    Rating NVARCHAR(10),
    Genre NVARCHAR(50),
    Director NVARCHAR(100),
    Description NVARCHAR(MAX),
    IsActive BIT DEFAULT 1
);

-- Таблица сеансов
CREATE TABLE MovieSession (
    SessionID INT PRIMARY KEY IDENTITY(1,1),
    MovieID INT NOT NULL,
    HallID INT NOT NULL,
    StartDateTime DATETIME NOT NULL,
    EndDateTime DATETIME NOT NULL,
    TicketPrice DECIMAL(10, 2) NOT NULL,
    Is3D BIT DEFAULT 0,
    CONSTRAINT FK_MovieSession_Movie FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
    CONSTRAINT FK_MovieSession_CinemaHall FOREIGN KEY (HallID) REFERENCES CinemaHall(HallID),
    CONSTRAINT CHK_EndAfterStart CHECK (EndDateTime > StartDateTime)
);

-- Таблица прокатов фильмов (дополнительная сущность)
CREATE TABLE MovieRental (
    RentalID INT PRIMARY KEY IDENTITY(1,1),
    MovieID INT NOT NULL,
    CinemaID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    RentalFee DECIMAL(12, 2) NOT NULL,
    ContractNumber NVARCHAR(50),
    CONSTRAINT FK_MovieRental_Movie FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
    CONSTRAINT FK_MovieRental_Cinema FOREIGN KEY (CinemaID) REFERENCES Cinema(CinemaID),
    CONSTRAINT CHK_ValidRentalPeriod CHECK (EndDate >= StartDate)
);

-- Таблица сотрудников (дополнительная сущность)
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    CinemaID INT NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Position NVARCHAR(50) NOT NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(10, 2),
    PhoneNumber NVARCHAR(20),
    Email NVARCHAR(100),
    CONSTRAINT FK_Employee_Cinema FOREIGN KEY (CinemaID) REFERENCES Cinema(CinemaID)
);
