USE [university_db]


-- 1. Добавить внешние ключи
ALTER TABLE [dbo].[student] 
ADD CONSTRAINT FK_student_group 
FOREIGN KEY (id_group) REFERENCES [dbo].[group](id_group);

ALTER TABLE [dbo].[lesson] 
ADD CONSTRAINT FK_lesson_teacher 
FOREIGN KEY (id_teacher) REFERENCES [dbo].[teacher](id_teacher);

ALTER TABLE [dbo].[lesson] 
ADD CONSTRAINT FK_lesson_subject 
FOREIGN KEY (id_subject) REFERENCES [dbo].[subject](id_subject);

ALTER TABLE [dbo].[lesson] 
ADD CONSTRAINT FK_lesson_group 
FOREIGN KEY (id_group) REFERENCES [dbo].[group](id_group);

ALTER TABLE [dbo].[mark] 
ADD CONSTRAINT FK_mark_lesson 
FOREIGN KEY (id_lesson) REFERENCES [dbo].[lesson](id_lesson);

ALTER TABLE [dbo].[mark] 
ADD CONSTRAINT FK_mark_student 
FOREIGN KEY (id_student) REFERENCES [dbo].[student](id_student);

-- 2. View для оценок студентов по информатике (с явным указанием возвращаемых столбцов)
CREATE VIEW InformaticsMarks AS
SELECT 
    s.id_student AS 'ID студента',
    s.name AS 'Фамилия студента',
    g.name AS 'Группа',
    sub.name AS 'Предмет',
    m.mark AS 'Оценка',
    l.date AS 'Дата занятия'
FROM [dbo].[mark] m
JOIN [dbo].[student] s ON m.id_student = s.id_student
JOIN [dbo].[lesson] l ON m.id_lesson = l.id_lesson
JOIN [dbo].[subject] sub ON l.id_subject = sub.id_subject
JOIN [dbo].[group] g ON s.id_group = g.id_group
WHERE sub.name = 'Информатика';

SELECT * FROM InformaticsMarks;

-- 3. Процедура для должников (с явным возвратом таблицы)
CREATE PROCEDURE GetDebtorsByGroup
    @group_id INT
AS
BEGIN
    SELECT 
        s.id_student AS 'ID студента',
        s.name AS 'Фамилия студента',
        g.name AS 'Группа',
        sub.name AS 'Предмет',
        l.date AS 'Дата занятия'
    FROM [dbo].[student] s
    JOIN [dbo].[group] g ON s.id_group = g.id_group
    JOIN [dbo].[lesson] l ON g.id_group = l.id_group
    JOIN [dbo].[subject] sub ON l.id_subject = sub.id_subject
    LEFT JOIN [dbo].[mark] m ON l.id_lesson = m.id_lesson AND m.id_student = s.id_student
    WHERE g.id_group = @group_id 
      AND m.id_mark IS NULL
    ORDER BY s.name, sub.name;
END;

EXEC GetDebtorsByGroup @group_id = 1;

-- 4. Средняя оценка по предметам с ≥35 студентами
SELECT sub.name AS subject_name, AVG(CAST(m.mark AS FLOAT)) AS average_mark
FROM [dbo].[subject] sub
JOIN [dbo].[lesson] l ON sub.id_subject = l.id_subject
JOIN [dbo].[mark] m ON l.id_lesson = m.id_lesson
GROUP BY sub.name
HAVING COUNT(DISTINCT m.id_student) >= 35
ORDER BY average_mark DESC;

-- 5. Оценки студентов специальности ВМ по всем предметам
SELECT g.name AS group_name, s.name AS student_name, sub.name AS subject_name, 
       l.date, m.mark
FROM [dbo].[group] g
JOIN [dbo].[student] s ON g.id_group = s.id_group
JOIN [dbo].[lesson] l ON g.id_group = l.id_group
JOIN [dbo].[subject] sub ON l.id_subject = sub.id_subject
LEFT JOIN [dbo].[mark] m ON l.id_lesson = m.id_lesson AND m.id_student = s.id_student
WHERE g.name = 'ВМ'
ORDER BY s.name, sub.name, l.date;

-- 6. Повышение оценок для студентов ПС по БД до 12.05
UPDATE m
SET m.mark = m.mark - 1
FROM [dbo].[mark] m
JOIN [dbo].[lesson] l ON m.id_lesson = l.id_lesson
JOIN [dbo].[subject] sub ON l.id_subject = sub.id_subject
JOIN [dbo].[student] s ON m.id_student = s.id_student
JOIN [dbo].[group] g ON s.id_group = g.id_group
WHERE g.name = 'ПС' 
  AND sub.name = 'БД' 
  AND l.date < '2023-05-12' 
  AND m.mark < 5;

-- 7. Добавление индексов
CREATE INDEX IX_student_group ON [dbo].[student](id_group);
CREATE INDEX IX_lesson_teacher ON [dbo].[lesson](id_teacher);
CREATE INDEX IX_lesson_subject ON [dbo].[lesson](id_subject);
CREATE INDEX IX_lesson_group ON [dbo].[lesson](id_group);
CREATE INDEX IX_mark_lesson ON [dbo].[mark](id_lesson);
CREATE INDEX IX_mark_student ON [dbo].[mark](id_student);
CREATE INDEX IX_lesson_date ON [dbo].[lesson](date);
CREATE INDEX IX_subject_name ON [dbo].[subject](name);
CREATE INDEX IX_group_name ON [dbo].[group](name);