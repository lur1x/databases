USE cinema_db;

/* 3.1 INSERT */

/* 3.1.a Без указания списка полей (в таблицу genre) */
INSERT INTO dbo.genre VALUES 
('Боевик', 'Фильмы с динамичными сценами и погонями'),
('Комедия', 'Юмористические фильмы'),
('Драма', 'Серьезные фильмы с глубоким сюжетом');
PRINT 'Добавлены основные жанры фильмов';


/* 3.1.b Вставка с указанием списка полей (в таблицу movie) */
INSERT INTO dbo.movie (title, duration, release_date, age_rating, description, id_genre)
VALUES 
('Крепкий орешек', 132, '1988-07-15', '18+', 'Классический боевик с Брюсом Уиллисом', 1),
('Маска', 101, '1994-07-29', '12+', 'Комедия с Джимом Керри', 2),
('Форрест Гамп', 142, '1994-07-06', '12+', 'Драматическая история простого человека', 3);
PRINT 'Добавлены популярные фильмы';


/* 3.1.c Вставка с чтением из другой таблицы (создадим архив фильмов) */
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'movie_archive')
BEGIN
    CREATE TABLE dbo.movie_archive (
        id_movie INT NOT NULL,
        title NVARCHAR(100) NOT NULL,
        release_year INT NOT NULL,
        archive_date DATETIME DEFAULT GETDATE()
    );
    PRINT 'Создана таблица movie_archive';
END

INSERT INTO dbo.movie_archive (id_movie, title, release_year)
SELECT id_movie, title, YEAR(release_date) 
FROM dbo.movie 
WHERE release_date < '2000-01-01';
PRINT 'Старые фильмы скопированы в архив';

/* 3.2 DELETE */

/* Создадим временную таблицу для демонстрации */
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'temp_movies')
BEGIN
    SELECT * INTO dbo.temp_movies FROM dbo.movie WHERE 1=0;
    PRINT 'Создана временная таблица temp_movies';
END

/* 3.2.a Удаление всех записей (очистка временной таблицы) */
DELETE FROM dbo.temp_movies;
PRINT 'Временная таблица фильмов очищена';

/* 3.2.b Удаление по условию (фильмы без описания) */
INSERT INTO dbo.movie (title, duration, release_date, age_rating) 
VALUES ('Тестовый фильм', 90, '2023-01-01', '18+');

DELETE FROM dbo.movie 
WHERE description IS NULL;
PRINT 'Удалены фильмы без описания';

/* 3.3 UPDATE */

/* 3.3.a Обновление всех записей (увеличение продолжительности на 5 минут) */
UPDATE dbo.movie 
SET duration = duration + 5;
PRINT 'Продолжительность всех фильмов увеличена на 5 минут';

/* 3.3.b Обновление одного атрибута по условию (изменение возрастного рейтинга) */
UPDATE dbo.movie 
SET age_rating = '18+' 
WHERE title LIKE '%орешек%';
PRINT 'Обновлен возрастной рейтинг для боевиков';

/* 3.3.c Обновление нескольких атрибутов по условию (изменение описания и продолжительности) */
UPDATE dbo.movie 
SET 
    description = 'Культовая комедия с Джимом Керри',
    duration = 105
WHERE title = 'Маска';
PRINT 'Обновлены данные по фильму "Маска"';

/* 3.4 SELECT */

/* 3.4.a Выборка конкретных атрибутов (название и продолжительность фильмов) */
SELECT title, duration 
FROM dbo.movie;
PRINT 'Получен список фильмов с продолжительностью';

/* 3.4.b Выборка всех атрибутов (все данные о фильмах) */
SELECT * 
FROM dbo.movie;
PRINT 'Получены все данные о фильмах';

/* 3.4.c Выборка с условием (длинные фильмы) */
SELECT * 
FROM dbo.movie 
WHERE duration > 120;
PRINT 'Получен список длинных фильмов';

/* 3.5 SELECT ORDER BY + TOP */

/* 3.5.a Сортировка по возрастанию с ограничением (3 самых коротких фильмов) */
SELECT TOP 3 title, duration 
FROM dbo.movie 
ORDER BY duration ASC;
PRINT 'Получены 3 самых коротких фильма';

/* 3.5.b Сортировка по убыванию (самые длинные фильмы) */
SELECT title, duration 
FROM dbo.movie 
ORDER BY duration DESC;
PRINT 'Фильмы отсортированы по убыванию продолжительности';

/* 3.5.c Сортировка по двум атрибутам (по жанру и продолжительности) */
SELECT TOP 5 title, id_genre, duration 
FROM dbo.movie 
ORDER BY id_genre, duration DESC;
PRINT 'Топ 5 фильмов по жанрам и продолжительности';

/* 3.5.d Сортировка по первому атрибуту (по названию) */
SELECT title, duration 
FROM dbo.movie 
ORDER BY 1;
PRINT 'Фильмы отсортированы по названию';

/* 3.6 Работа с датами */

/* Добавим тестовые данные в cinema, hall и screening для демонстрации */
INSERT INTO dbo.cinema (name, address, opening_time, closing_time) 
VALUES ('Киномакс', 'ул. Кинотеатральная, 1', '09:00', '23:00');

INSERT INTO dbo.hall (name, capacity, id_cinema, has_3d, has_dolby) 
VALUES ('Зал 1', 150, 1, 1, 1);

INSERT INTO dbo.screening (start_time, id_movie, id_hall, is_premiere)
VALUES 
('2023-11-15 12:00:00', 1, 1, 0),
('2023-11-15 15:00:00', 2, 1, 0),
('2023-11-15 18:00:00', 3, 1, 0),
('2022-05-10 20:00:00', 1, 1, 1);

/* 3.6.a WHERE по дате (сеансы на конкретный день) */
SELECT * 
FROM dbo.screening 
WHERE CAST(start_time AS DATE) = '2023-11-15';
PRINT 'Сеансы на 15 ноября 2023';

/* 3.6.b WHERE дата в диапазоне (сеансы за последний месяц) */
SELECT * 
FROM dbo.screening 
WHERE start_time BETWEEN DATEADD(month, -1, GETDATE()) AND GETDATE();
PRINT 'Сеансы за последний месяц';

/* 3.6.c Извлечение года из даты (статистика по годам) */
SELECT YEAR(start_time) AS year, COUNT(*) AS screening_count 
FROM dbo.screening 
GROUP BY YEAR(start_time);
PRINT 'Количество сеансов по годам';

/* 3.7 Функции агрегации */

/* 3.7.a Количество записей (всего фильмов) */
SELECT COUNT(*) AS total_movies 
FROM dbo.movie;
PRINT 'Общее количество фильмов';

/* 3.7.b Количество уникальных записей (уникальных жанров) */
SELECT COUNT(DISTINCT id_genre) AS unique_genres 
FROM dbo.movie;
PRINT 'Количество используемых жанров';

/* 3.7.c Уникальные значения (все используемые возрастные рейтинги) */
SELECT DISTINCT age_rating 
FROM dbo.movie;
PRINT 'Список используемых возрастных рейтингов';

/* 3.7.d Максимальное значение (максимальная продолжительность) */
SELECT MAX(duration) AS max_duration 
FROM dbo.movie;
PRINT 'Максимальная продолжительность фильма';

/* 3.7.e Минимальное значение (минимальная продолжительность) */
SELECT MIN(duration) AS min_duration 
FROM dbo.movie;
PRINT 'Минимальная продолжительность фильма';

/* 3.7.f COUNT + GROUP BY (количество фильмов по жанрам) */
SELECT id_genre, COUNT(*) AS movie_count 
FROM dbo.movie 
GROUP BY id_genre;
PRINT 'Количество фильмов по жанрам';

/* 3.8 SELECT GROUP BY + HAVING */

/* Добавим тестовые данные в ticket */
INSERT INTO dbo.customer (first_name, last_name) VALUES ('Иван', 'Иванов');
INSERT INTO dbo.price (name, amount) VALUES ('Стандарт', 300), ('VIP', 500);

INSERT INTO dbo.ticket (id_screening, id_customer, id_price, seat_number)
VALUES 
(1, 1, 1, 'A1'),
(1, 1, 1, 'A2'),
(2, 1, 2, 'B3'),
(3, 1, 1, 'C4');

/* 3.8.a Фильмы с количеством сеансов больше 1 */
SELECT 
    m.title,
    COUNT(s.id_screening) AS screening_count
FROM dbo.movie m
JOIN dbo.screening s ON m.id_movie = s.id_movie
GROUP BY m.title
HAVING COUNT(s.id_screening) > 1;
PRINT 'Фильмы с более чем одним сеансом';

/* 3.8.b Кинотеатры с залами, поддерживающими 3D */
SELECT 
    c.name,
    COUNT(h.id_hall) AS halls_with_3d
FROM dbo.cinema c
JOIN dbo.hall h ON c.id_cinema = h.id_cinema
WHERE h.has_3d = 1
GROUP BY c.name
HAVING COUNT(h.id_hall) > 0;
PRINT 'Кинотеатры с залами, поддерживающими 3D';

/* 3.8.c Типы билетов, которые покупали более 1 раза */
SELECT 
    p.name,
    COUNT(t.id_ticket) AS ticket_count
FROM dbo.price p
JOIN dbo.ticket t ON p.id_price = t.id_price
GROUP BY p.name
HAVING COUNT(t.id_ticket) > 1;
PRINT 'Типы билетов, купленные более 1 раза';

/* 3.9 SELECT JOIN */

/* 3.9.a LEFT JOIN (фильмы с их жанрами) */
SELECT 
    m.title,
    g.name AS genre
FROM dbo.movie m
LEFT JOIN dbo.genre g ON m.id_genre = g.id_genre;
PRINT 'Фильмы с их жанрами';

/* 3.9.b RIGHT JOIN (аналогично предыдущему, но через RIGHT JOIN) */
SELECT 
    m.title,
    g.name AS genre
FROM dbo.genre g
RIGHT JOIN dbo.movie m ON g.id_genre = m.id_genre;
PRINT 'Фильмы с их жанрами (через RIGHT JOIN)';

/* 3.9.c LEFT JOIN трех таблиц (сеансы с фильмами и залами) */
SELECT 
    s.start_time,
    m.title,
    h.name AS hall_name
FROM dbo.screening s
LEFT JOIN dbo.movie m ON s.id_movie = m.id_movie
LEFT JOIN dbo.hall h ON s.id_hall = h.id_hall
WHERE 
    s.start_time > '2023-01-01'
    AND m.duration > 100
    AND h.capacity > 100;
PRINT 'Сеансы с фильмами и залами с фильтрами';

/* 3.9.d INNER JOIN (билеты с информацией о сеансах) */
SELECT 
    t.seat_number,
    m.title,
    s.start_time
FROM dbo.ticket t
INNER JOIN dbo.screening s ON t.id_screening = s.id_screening
INNER JOIN dbo.movie m ON s.id_movie = m.id_movie;
PRINT 'Билеты с информацией о сеансах';

/* 3.10 Подзапросы */

/* 3.10.a WHERE IN (фильмы, на которые есть билеты) */
SELECT * 
FROM dbo.movie
WHERE id_movie IN (
    SELECT DISTINCT s.id_movie 
    FROM dbo.screening s
    JOIN dbo.ticket t ON s.id_screening = t.id_screening
);
PRINT 'Фильмы, на которые есть билеты';

/* 3.10.b SELECT подзапрос (фильмы с количеством сеансов) */
SELECT 
    m.title,
    (SELECT COUNT(*) 
     FROM dbo.screening s 
     WHERE s.id_movie = m.id_movie) AS screening_count
FROM dbo.movie m;
PRINT 'Фильмы с количеством сеансов';

/* 3.10.c FROM подзапрос (топ-2 самых длинных фильма) */
SELECT * FROM (
    SELECT 
        title,
        duration,
        RANK() OVER (ORDER BY duration DESC) AS rank
    FROM dbo.movie
) AS ranked_movies
WHERE rank <= 2;
PRINT 'Топ-2 самых длинных фильма';

/* 3.10.d JOIN подзапрос (кинотеатры с количеством залов) */
SELECT 
    c.name,
    c.address,
    h.hall_count
FROM dbo.cinema c
JOIN (
    SELECT 
        id_cinema, 
        COUNT(*) AS hall_count
    FROM dbo.hall
    GROUP BY id_cinema
) AS h ON c.id_cinema = h.id_cinema;
PRINT 'Кинотеатры с количеством залов';

PRINT 'Все запросы для cinema_db выполнены успешно';