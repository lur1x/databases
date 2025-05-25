CREATE DATABASE hotel_db

USE hotel_db;

--1. Добавить внешние ключи

-- добавляем внешние ключи
ALTER TABLE room
    ADD CONSTRAINT fk_hotel
        FOREIGN KEY (id_hotel)
            REFERENCES hotel (id_hotel) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE room
    ADD CONSTRAINT fk_room_category
        FOREIGN KEY (id_room_category)
            REFERENCES room_category (id_room_category) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE booking
    ADD CONSTRAINT fk_client
        FOREIGN KEY (id_client)
            REFERENCES client (id_client) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE room_in_booking
    ADD CONSTRAINT fk_booking
        FOREIGN KEY (id_booking)
            REFERENCES booking (id_booking) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE room_in_booking
    ADD CONSTRAINT fk_room
        FOREIGN KEY (id_room)
            REFERENCES room (id_room) ON DELETE CASCADE ON UPDATE CASCADE;


--2. Выдать информацию о клиентах гостиницы "Космос", проживающих в номерах
--категории "Люкс" на 1 апреля 2019г.
SELECT client.id_client, client.name, client.phone
FROM client
    JOIN booking ON client.id_client = booking.id_client
    JOIN room_in_booking ON booking.id_booking = room_in_booking.id_booking
    JOIN room ON room_in_booking.id_room = room.id_room
    JOIN hotel ON room.id_hotel = hotel.id_hotel
    JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE hotel.name = 'Космос'
    AND room_category.name = 'Люкс'
    AND room_in_booking.checkin_date <= '2019-04-01'
    AND room_in_booking.checkout_date > '2019-04-01';


--3. Дать список свободных номеров всех гостиниц на 22 апреля.
SELECT hotel.id_hotel,
    hotel.name,
    hotel.stars,
    room.id_room,
    room.number,
    room.price,
    room_category.name AS category_name,
    room_category.square
FROM room
    JOIN hotel ON room.id_hotel = hotel.id_hotel
    JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE room.id_room NOT IN (
    SELECT id_room
    FROM room_in_booking
    WHERE checkin_date <= '2019-04-22'
        AND checkout_date > '2019-04-22'
);


--4. Дать количество проживающих в гостинице "Космос" на 23 марта по каждой
--категории номеров
SELECT 
    room_category.name AS category_name, 
    COUNT(DISTINCT booking.id_client) AS client_count
FROM room_in_booking
    JOIN booking ON room_in_booking.id_booking = booking.id_booking
    JOIN room ON room_in_booking.id_room = room.id_room
    JOIN hotel ON room.id_hotel = hotel.id_hotel
    JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE hotel.name = 'Космос'
    AND room_in_booking.checkin_date <= '2019-03-23'
    AND room_in_booking.checkout_date > '2019-03-23'
GROUP BY room_category.name
ORDER BY client_count DESC;


--5. Дать список последних проживавших клиентов по всем комнатам гостиницы
--"Космос", выехавшим в апреле с указанием даты выезда.
WITH LastCheckouts AS (
    SELECT 
        id_room, 
        MAX(checkout_date) AS last_checkout_date
    FROM room_in_booking
    WHERE MONTH(checkout_date) = 4
    GROUP BY id_room
)
SELECT 
    client.name,
    client.phone,
    room.id_room,
    room.number,
    room_category.name AS category_name,
    room_in_booking.checkout_date
FROM LastCheckouts
    JOIN room_in_booking ON LastCheckouts.id_room = room_in_booking.id_room
        AND LastCheckouts.last_checkout_date = room_in_booking.checkout_date
    JOIN booking ON room_in_booking.id_booking = booking.id_booking
    JOIN client ON booking.id_client = client.id_client
    JOIN room ON room_in_booking.id_room = room.id_room
    JOIN hotel ON room.id_hotel = hotel.id_hotel
    JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE hotel.name = 'Космос';


--6. Продлить на 2 дня дату проживания в гостинице "Космос" всем клиентам
--комнат категории "Бизнес", которые заселились 10 мая.
UPDATE room_in_booking
SET checkout_date = DATEADD(day, 2, checkout_date)
FROM room_in_booking rib
    JOIN room ON rib.id_room = room.id_room
    JOIN hotel ON room.id_hotel = hotel.id_hotel
    JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE hotel.name = 'Космос'
    AND room_category.name = 'Бизнес'
    AND rib.checkin_date = '2019-05-10';


--7. Найти все "пересекающиеся" варианты проживания
SELECT 
    r1.id_room_in_booking AS first_booking_id,
    r2.id_room_in_booking AS second_booking_id,
    r1.id_room,
    room.number AS room_number,
    hotel.name AS hotel_name,
    r1.checkin_date AS first_checkin,
    r1.checkout_date AS first_checkout,
    r2.checkin_date AS second_checkin,
    r2.checkout_date AS second_checkout
FROM room_in_booking r1
    JOIN room_in_booking r2 ON r1.id_room = r2.id_room
    JOIN room ON r1.id_room = room.id_room
    JOIN hotel ON room.id_hotel = hotel.id_hotel
WHERE r1.id_room_in_booking < r2.id_room_in_booking
    AND (
        (r1.checkin_date <= r2.checkin_date AND r1.checkout_date > r2.checkin_date)
        OR (r2.checkin_date <= r1.checkin_date AND r2.checkout_date > r1.checkin_date)
    );


--8. Создать бронирование в транзакции
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @id_client INT = 1; -- ID клиента
    DECLARE @id_room INT = 103; -- ID номера
    DECLARE @checkin_date DATE = '2020-01-15'; -- Дата заезда
    DECLARE @checkout_date DATE = '2020-01-20'; -- Дата выезда
    DECLARE @booking_id INT; -- Переменная для хранения ID нового бронирования

    -- Проверка доступности номера
    IF EXISTS (
        SELECT 1
        FROM room_in_booking rib
        WHERE rib.id_room = @id_room
            AND (
                (@checkin_date >= rib.checkin_date AND @checkin_date < rib.checkout_date)
                OR (@checkout_date > rib.checkin_date AND @checkout_date <= rib.checkout_date)
                OR (@checkin_date <= rib.checkin_date AND @checkout_date >= rib.checkout_date)
            )
    )
    BEGIN
        THROW 50000, 'Номер уже забронирован на указанные даты.', 1;
    END;

    -- Создание записи о бронировании
    INSERT INTO booking (id_client, booking_date)
    VALUES (@id_client, GETDATE());
    
    SET @booking_id = SCOPE_IDENTITY();

    -- Создание записи о бронировании номера
    INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
    VALUES (@booking_id, @id_room, @checkin_date, @checkout_date);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Ошибка при создании бронирования: ' + ERROR_MESSAGE();
END CATCH;


--9. Добавить необходимые индексы для всех таблиц
CREATE INDEX idx_hotel_name ON hotel (name);
CREATE INDEX idx_room_category_name ON room_category (name);
CREATE INDEX idx_room_id ON room (id_room);
CREATE INDEX idx_room_hotel ON room (id_hotel);
CREATE INDEX idx_room_category ON room (id_room_category);
CREATE INDEX idx_room_number ON room (number);
CREATE INDEX idx_room_in_booking_room ON room_in_booking (id_room);
CREATE INDEX idx_room_in_booking_booking ON room_in_booking (id_booking);
CREATE INDEX idx_room_in_booking_dates ON room_in_booking (checkin_date, checkout_date);
CREATE INDEX idx_booking_client ON booking (id_client);
CREATE INDEX idx_booking_date ON booking (booking_date);
CREATE INDEX idx_client_phone ON client (phone);
CREATE INDEX idx_client_name ON client (name);
CREATE INDEX idx_room_in_booking_checkin ON room_in_booking (checkin_date);
CREATE INDEX idx_room_in_booking_checkout ON room_in_booking (checkout_date);