USE university;

-- 1. Добавить внешние ключи.

ALTER TABLE student
ADD CONSTRAINT FK_student_group
FOREIGN KEY (id_group) REFERENCES [group](id_group);

ALTER TABLE lesson
ADD CONSTRAINT FK_lesson_teacher
FOREIGN KEY (id_teacher) REFERENCES teacher(id_teacher);

ALTER TABLE lesson
ADD CONSTRAINT FK_lesson_subject
FOREIGN KEY (id_subject) REFERENCES subject(id_subject);

ALTER TABLE lesson
ADD CONSTRAINT FK_lesson_group
FOREIGN KEY (id_group) REFERENCES [group](id_group);

ALTER TABLE mark
ADD CONSTRAINT FK_mark_lesson
FOREIGN KEY (id_lesson) REFERENCES lesson(id_lesson);

ALTER TABLE mark
ADD CONSTRAINT FK_mark_student
FOREIGN KEY (id_student) REFERENCES student(id_student);

-- 2. Выдать оценки студентов по информатике если они обучаются данному
-- предмету. Оформить выдачу данных с использованием view.

DROP VIEW IF EXISTS university.informatics_students_marks;

CREATE VIEW informatics_students_marks AS
SELECT
  st.id_student,
  st.name,
  STRING_AGG(m.mark, ', ') 'marks'
FROM
  lesson l
  INNER JOIN subject s ON s.id_subject = l.id_subject
  INNER JOIN mark m ON m.id_lesson = l.id_lesson
  INNER JOIN student st ON st.id_student = m.id_student
WHERE
  s.name = N'Информатика'
GROUP BY
  st.id_student,
  st.name
;

-- 3. Дать информацию о должниках с указанием фамилии студента и названия
-- предмета. Должниками считаются студенты, не имеющие оценки по предмету,
-- который ведется в группе. Оформить в виде процедуры, на входе
-- идентификатор группы.

DROP PROCEDURE IF EXISTS students_without_marks;
CREATE PROCEDURE students_without_marks 
  @id_group INT
AS
  SELECT
    (SELECT t.name FROM [group] t WHERE t.id_group = @id_group) 'group',
	(SELECT t.name FROM student t WHERE t.id_student = st.id_student) 'student',
	(SELECT t.name FROM subject t WHERE t.id_subject = s.id_subject) 'subject'
  FROM 
	[group] g
	INNER JOIN lesson l ON l.id_group = g.id_group
	INNER JOIN student st ON st.id_group = g.id_group
	LEFT JOIN mark m ON m.id_student = st.id_student AND m.id_lesson = l.id_lesson
	LEFT JOIN subject AS s ON s.id_subject = l.id_subject
  WHERE
	g.id_group = @id_group
  GROUP BY
   g.id_group,
   st.id_student,
   s.id_subject
  HAVING
    COUNT(m.id_mark) = 0
  ORDER BY 1, 2, 3
;

DECLARE @id_group INT;
SET @id_group = (SELECT g.id_group FROM [group] AS g WHERE g.name = N'ПС');
EXECUTE students_without_marks @id_group = @id_group;

-- 4. Дать среднюю оценку студентов по каждому предмету для тех предметов, по
-- которым занимается не менее 35 студентов.

SELECT
  s.id_subject,
  s.name,
  COUNT(DISTINCT st.id_student) 'students_count',
  SUM(m.mark) / COUNT(m.mark) 'average_mark'
FROM
  lesson l
  INNER JOIN subject s ON s.id_subject = l.id_subject
  INNER JOIN [group] g ON g.id_group = l.id_group
  INNER JOIN student st ON st.id_group = g.id_group
  LEFT JOIN mark m ON m.id_student = st.id_student
GROUP BY
  s.id_subject,
  s.name
HAVING
  COUNT(DISTINCT st.id_student) >= 35
;

-- 5. Дать оценки студентов специальности ВМ по всем проводимым предметам с
-- указанием группы, фамилии, предмета, даты. При отсутствии оценки заполнить
-- значениями NULL поля оценки.

SELECT
  st.name 'student',
  g.name 'group',
  s.name 'subject',
  l.date,
  m.mark
FROM
  student st
  INNER JOIN [group] g ON g.id_group = st.id_group
  INNER JOIN lesson l ON l.id_group = g.id_group
  INNER JOIN subject s ON s.id_subject = l.id_subject
  LEFT JOIN mark m ON m.id_student = st.id_student AND m.id_lesson = l.id_lesson
WHERE
  g.name = N'ВМ'
;

-- 6. Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету
-- БД до 12.05, повысить эти оценки на 1 балл.

BEGIN TRANSACTION

UPDATE
  mark
SET
  mark = mark + 1
FROM
  student st
  INNER JOIN [group] g ON g.id_group = st.id_group
  INNER JOIN lesson l ON l.id_group = g.id_group
  INNER JOIN subject s ON s.id_subject = l.id_subject
  INNER JOIN mark m ON m.id_student = st.id_student AND m.id_lesson = l.id_lesson
WHERE
  g.name = N'ПС'
  AND s.name = N'БД'
  AND l.date < '2019-05-12'
  AND m.mark < 5

ROLLBACK

-- 7. Добавить необходимые индексы.

CREATE NONCLUSTERED INDEX [IX_subject_name]
ON subject (name)

CREATE NONCLUSTERED INDEX [IX_group_name]
ON [group] (name)

CREATE NONCLUSTERED INDEX [IX_lesson_date]
ON lesson (date)