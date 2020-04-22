select 'drop table if exists "' || tablename || '";'
  from pg_tables
where schemaname = 'public';

drop table if exists "salon";
drop table if exists "employee";
drop table if exists "position";
drop table if exists "employee_salon_position";
drop table if exists "client";
drop table if exists "client_visit";
drop table if exists "client_visit_service";
drop table if exists "employee_service";
drop table if exists "service";


create table if not exists salon (
  id_salon serial primary key,
  country varchar (50) not null,
  city varchar (50) not null,
  address varchar (100) not null
);

create table if not exists employee (
  id_employee serial primary key,
  first_name varchar (50) not null,
  last_name varchar (50) not null,
  created_at timestamp not null default now(),
  deleted_at timestamp
);

create table if not exists position (
  id_position serial primary key,
  name varchar (50) not null
);

create table if not exists employee_salon_position (
  id_employee_salon_position serial primary key,
  id_employee int not null,
  id_salon int not null,
  id_position int not null,
  created_at timestamp not null default now(),
  deleted_at timestamp
);

create table if not exists service (
  id_service serial primary key,
  name varchar (50) not null
);

create table if not exists employee_service (
  id_employee_service serial primary key,
  id_employee_salon_position int not null,
  id_service int not null,
  cost numeric(7, 2) not null,
  duration int not null
);

create table if not exists client (
  id_client serial primary key,
  first_name varchar (50) not null,
  last_name varchar (50) not null,
  created_at timestamp not null default now(),
  deleted_at timestamp,
  discount_percent numeric (4, 2) not null default '0'
);

create table if not exists client_visit (
  id_client_visit serial primary key,
  id_client int not null,
  id_salon int not null,
  date date not null,
  total numeric(7, 2) not null default 0,
  discount numeric(7, 2) not null default 0
);

create table if not exists client_visit_service (
  id_client_visit_service serial primary key,
  id_client_visit int not null,
  id_employee_service int not null,
  scheduled_start_time time,
  actual_start_time time
);

-- 1. INSERT

insert into salon
values
  (DEFAULT, 'Россия', 'Москва', 'ул. Гарибальди, д. 15'),
  (DEFAULT, 'Россия', 'Москва', 'ул. Кржижановского д.24/35 к. 2'),
  (DEFAULT, 'Россия', 'Санкт-Петербург', 'ул. Бочкова д. 3'),
  (DEFAULT, 'Россия', 'Казань', 'ул. Сущевская д. 25, стр. 4'),
  (DEFAULT, 'Россия', 'Казань', 'ул. Пушкина д. 21')
;

insert into employee (last_name, first_name)
values
  ('Лаврентьева', 'Полина'),
  ('Русакова', 'Виктория'),
  ('Родионова', 'Татьяна'),
  ('Ермакова', 'Ульяна'),
  ('Романенко', 'Евгений'),
  ('Маслов', 'Эрик')
;

insert into position
values
  (DEFAULT, 'Парикмахер-универсал'),
  (DEFAULT, 'Парикмахер-стилист'),
  (DEFAULT, 'Парикмахер-колорист'),
  (DEFAULT, 'Стилист-визажист'),
  (DEFAULT, 'Мастер ногтевого сервиса'),
  (DEFAULT, 'Массажист')
;

insert into employee_salon_position (id_salon, id_position, id_employee)
values
  (
  (select id_salon from salon where address = 'ул. Гарибальди, д. 15'),
  (select id_position from position where name = 'Парикмахер-универсал'),
  (select id_employee from employee where last_name = 'Лаврентьева')
  ),
  (
  (select id_salon from salon where address = 'ул. Кржижановского д.24/35 к. 2'),
  (select id_position from position where name = 'Парикмахер-стилист'),
  (select id_employee from employee where last_name = 'Русакова')
  ),
  (
  (select id_salon from salon where address = 'ул. Бочкова д. 3'),
  (select id_position from position where name = 'Парикмахер-колорист'),
  (select id_employee from employee where last_name = 'Родионова')
  ),
  (
  (select id_salon from salon where address = 'ул. Сущевская д. 25, стр. 4'),
  (select id_position from position where name = 'Стилист-визажист'),
  (select id_employee from employee where last_name = 'Ермакова')
  ),
  (
  (select id_salon from salon where address = 'ул. Пушкина д. 21'),
  (select id_position from position where name = 'Мастер ногтевого сервиса'),
  (select id_employee from employee where last_name = 'Романенко')
  ),
  (
  (select id_salon from salon where address = 'ул. Пушкина д. 21'),
  (select id_position from position where name = 'Массажист'),
  (select id_employee from employee where last_name = 'Маслов')
  )
;

insert into service
values
  (DEFAULT, 'Стрижка'),
  (DEFAULT, 'Укладка (повседневная)'),
  (DEFAULT, 'Укладка (вечерняя)'),
  (DEFAULT, 'Окрашивание волос (длинные)'),
  (DEFAULT, 'Окрашивание волос (средние)'),
  (DEFAULT, 'Окрашивание волос (короткие)'),
  (DEFAULT, 'Макияж (повседневный)'),
  (DEFAULT, 'Макияж (вечерний)'),
  (DEFAULT, 'Маникюр (классический)'),
  (DEFAULT, 'Маникюр (японский)'),
  (DEFAULT, 'Покрытие (лак)'),
  (DEFAULT, 'Покрытие (гель-лак)'),
  (DEFAULT, 'Укрепление ногтевой пластины'),
  (DEFAULT, 'Дизайн (1 ноготь)'),
  (DEFAULT, 'Массаж стоп и голеней'),
  (DEFAULT, 'Массаж спины'),
  (DEFAULT, 'Массаж шейно-воротниковой зоны'),
  (DEFAULT, 'Массаж (общий)'),
  (DEFAULT, 'Массаж (оздоровительный)')
;

insert into employee_service (id_employee_salon_position, id_service, cost, duration)
values
  (1, (select id_service from service where name='Стрижка'), 400, 40),
  (1, (select id_service from service where name='Укладка (повседневная)'), 500, 30),
  (1, (select id_service from service where name='Укладка (вечерняя)'), 700, 50),
  (1, (select id_service from service where name='Окрашивание волос (длинные)'), 1100, 120),
  (1, (select id_service from service where name='Окрашивание волос (средние)'), 900, 120),
  (1, (select id_service from service where name='Окрашивание волос (короткие)'), 700, 90),
  (2, (select id_service from service where name='Стрижка'), 700, 40),
  (2, (select id_service from service where name='Укладка (повседневная)'), 600, 30),
  (2, (select id_service from service where name='Укладка (вечерняя)'), 800, 50),
  (3, (select id_service from service where name='Стрижка'), 500, 40),
  (3, (select id_service from service where name='Окрашивание волос (длинные)'), 1300, 120),
  (3, (select id_service from service where name='Окрашивание волос (средние)'), 1100, 120),
  (3, (select id_service from service where name='Окрашивание волос (короткие)'), 900, 90),
  (4, (select id_service from service where name='Макияж (повседневный)'), 900, 30),
  (4, (select id_service from service where name='Макияж (вечерний)'), 1200, 50),
  (5, (select id_service from service where name='Маникюр (классический)'), 400, 30),
  (5, (select id_service from service where name='Маникюр (японский)'), 600, 50),
  (5, (select id_service from service where name='Покрытие (лак)'), 200, 30),
  (5, (select id_service from service where name='Покрытие (гель-лак)'), 300, 40),
  (5, (select id_service from service where name='Укрепление ногтевой пластины'), 200, 20),
  (5, (select id_service from service where name='Дизайн (1 ноготь)'), 50, 10),
  (6, (select id_service from service where name='Массаж стоп и голеней'), 600, 40),
  (6, (select id_service from service where name='Массаж спины'), 900, 50),
  (6, (select id_service from service where name='Массаж шейно-воротниковой зоны'), 700, 40),
  (6, (select id_service from service where name='Массаж (общий)'), 1200, 60),
  (6, (select id_service from service where name='Массаж (оздоровительный)'), 1400, 60)
;

insert into client (first_name, last_name, discount_percent)
values
  ('Субботина', 'Янина', DEFAULT),
  ('Блинова', 'Капитолина', 0.03),
  ('Ларионова', 'Валерия', DEFAULT),
  ('Сердюк', 'Елена', 0.05),
  ('Самойлова', 'Оксана', 0.03),
  ('Галкина', 'Ксения', DEFAULT),
  ('Исакова', 'Дарья', 0.05),
  ('Трублаевская', 'Альбина ', DEFAULT),
  ('Никонова', 'Марина', DEFAULT),
  ('Егорова', 'Светлана', 0.1)
;

insert into client_visit (id_client, id_salon, date)
values
  (1, 1, '2020-01-02'),
  (1, 4, '2020-01-26'),
  (1, 1, '2020-02-15'),
  (1, 5, '2020-03-20'),
  (2, 1, '2020-01-10'),
  (2, 2, '2020-01-30'),
  (2, 2, '2020-02-07'),
  (2, 5, '2020-02-29'),
  (2, 3, '2020-03-12'),
  (2, 1, '2020-03-21'),
  (3, 4, '2020-01-11'),
  (3, 1, '2020-01-17'),
  (3, 2, '2020-01-28'),
  (3, 3, '2020-02-08'),
  (3, 4, '2020-02-18'),
  (3, 3, '2020-03-02'),
  (3, 3, '2020-03-17'),
  (3, 5, '2020-03-22'),
  (3, 5, '2020-03-22'),
  (4, 2, '2020-01-05'),
  (4, 2, '2020-01-25'),
  (4, 2, '2020-02-09'),
  (4, 4, '2020-02-21'),
  (4, 5, '2020-02-25'),
  (5, 1, '2020-01-06'),
  (5, 1, '2020-01-24'),
  (5, 1, '2020-02-01'),
  (5, 1, '2020-02-25')
;

insert into client_visit_service (id_client_visit, id_employee_service, scheduled_start_time, actual_start_time)
values
  (1, 1, '10:00', '10:00'),
  (1, 2, '10:40', '10:40'),
  (2, 15, '17:30', '17:30'),
  (3, 1, '12:00', '12:00'),
  (3, 4, '12:40', '12:50'),
  (4, 16, '11:00', '11:00'),
  (4, 19, '11:30', '11:30'),
  (5, 1, '11:30', '11:30'),
  (6, 9, '18:30', '18:30'),
  (7, 7, '12:30', '12:30'),
  (7, 8, '13:10', '13:40'),
  (7, 8, '13:10', '13:40'),
  (8, 16, '14:00', '14:00'),
  (8, 19, '14:30', '14:30'),
  (8, 24, '15:10', '15:10'),
  (9, 11, '10:00', '10:00'),
  (10, 1, '9:00', '9:00'),
  (10, 5, '9:40', '9:40'),
  (11, 14, '9:30', '9:30'),
  (11, 14, '9:30', '9:30'),
  (12, 6, '13:30', '13:30'),
  (12, 2, '15:00', '15:00'),
  (13, 8, '10:10', '10:10'),
  (14, 10, '15:40', '15:40'),
  (15, 15, '18:00', '18:00'),
  (16, 10, '11:00', '11:00'),
  (17, 10, '11:00', '11:00'),
  (17, 12, '11:40', '11:40'),
  (18, 17, '12:00', '12:10'),
  (19, 25, '11:30', '11:30'),
  (19, 25, '11:30', '11:30'),
  (20, 7, '11:00', '11:00'),
  (20, 8, '11:40', '11:40'),
  (21, 8, '8:30', '8:30'),
  (22, 9, '17:00', '17:10'),
  (23, 15, '17:00', '17:15'),
  (24, 16, '9:00', '9:00'),
  (24, 20, '9:30', '9:30'),
  (24, 18, '9:50', '9:50'),
  (25, 6, '9:50', '9:50'),
  (26, 1, '10:30', '10:30'),
  (27, 5, '15:30', '15:30'),
  (27, 2, '17:30', '17:30'),
  (28, 2, '9:00', '9:00')
;

-- 2. DELETE

DELETE FROM service;
DELETE FROM service WHERE name like 'Массаж%';
TRUNCATE TABLE service RESTART IDENTITY;

-- 3. UPDATE

UPDATE employee_service SET cost = cost * 1.10;

UPDATE salon
SET address = 'ул. Павлова д. 25'
WHERE address = 'ул. Пушкина д. 21';

UPDATE employee_service
SET cost = 600, duration = 30
WHERE
  id_employee_salon_position = (
      SELECT
        esp.id_employee_salon_position
      FROM
        employee_salon_position esp
        INNER JOIN employee e USING (id_employee)
      WHERE
        e.last_name = 'Родионова'
    )
  AND id_service = (
    SELECT s.id_service
    FROM service s
    WHERE s.name = 'Стрижка'
  )
;

-- 4. SELECT

SELECT
  s.address,
  e.first_name,
  e.last_name,
  p.name
FROM
  employee_salon_position esp
  INNER JOIN salon s USING (id_salon)
  INNER JOIN employee e USING (id_employee)
  INNER JOIN position p USING (id_position)
;

SELECT
  *
FROM
  employee_salon_position esp
  INNER JOIN salon s USING (id_salon)
  INNER JOIN employee e USING (id_employee)
  INNER JOIN position p USING (id_position)
;

SELECT
  s.address,
  e.first_name,
  e.last_name,
  p.name
FROM
  employee_salon_position esp
  INNER JOIN salon s USING (id_salon)
  INNER JOIN employee e USING (id_employee)
  INNER JOIN position p USING (id_position)
WHERE
  s.city = 'Казань'
;

-- 5. SELECT ORDER BY + TOP (LIMIT)

SELECT
  s.name,
  e.first_name,
  e.last_name,
  es.cost
FROM
  employee_service es
  INNER JOIN employee_salon_position esp ON es.id_employee_salon_position = esp.id_employee_salon_position
  INNER JOIN service s ON es.id_service = s.id_service
  INNER JOIN employee e ON esp.id_employee = e.id_employee
WHERE
  s.name LIKE 'Окрашивание%'
ORDER BY es.cost
LIMIT 3
;

SELECT
  s.name,
  e.first_name,
  e.last_name,
  es.cost
FROM
  employee_service es
  INNER JOIN employee_salon_position esp ON es.id_employee_salon_position = esp.id_employee_salon_position
  INNER JOIN service s ON es.id_service = s.id_service
  INNER JOIN employee e ON esp.id_employee = e.id_employee
WHERE
  s.name LIKE 'Окрашивание%'
ORDER BY es.cost DESC
;

SELECT
  s.name,
  e.first_name,
  e.last_name,
  es.cost,
  es.duration
FROM
  employee_service es
  INNER JOIN employee_salon_position esp ON es.id_employee_salon_position = esp.id_employee_salon_position
  INNER JOIN service s ON es.id_service = s.id_service
  INNER JOIN employee e ON esp.id_employee = e.id_employee
WHERE
  s.name LIKE 'Окрашивание%'
ORDER BY es.cost DESC, es.duration
LIMIT 5
;

SELECT
  e.last_name,
  e.first_name,
  s.name,
  es.cost
FROM
  employee_service es
  INNER JOIN employee_salon_position esp ON es.id_employee_salon_position = esp.id_employee_salon_position
  INNER JOIN service s ON es.id_service = s.id_service
  INNER JOIN employee e ON esp.id_employee = e.id_employee
WHERE
  s.name LIKE 'Окрашивание%'
ORDER BY 1
;

-- 6. Работа с датами

SELECT
  c.last_name,
  c.first_name,
  cv.date
FROM
  client_visit cv
  INNER JOIN client c ON cv.id_client = c.id_client
WHERE
  cv.date >= '2020-03-01'
;

SELECT
  c.last_name,
  c.first_name,
  cv.date,
  DATE_PART('year', cv.date) visit_year
FROM
  client_visit cv
  INNER JOIN client c ON cv.id_client = c.id_client
WHERE
  DATE_PART('month', cv.date) >= 3
;

-- 7. SELECT GROUP BY с функциями агрегации
-- поиск минимальной и максимальной скидки клиента
SELECT
  MIN(c.discount_percent) min_client_discount,
  MAX(c.discount_percent) max_client_discount
FROM client c
WHERE
  c.discount_percent > 0
;

-- вычисление средней продолжительности оказания услуги - Окрашивание волос любой длины
SELECT
  AVG(es.duration) avg_service_duration
FROM
  employee_service es
  INNER JOIN employee_salon_position esp ON es.id_employee_salon_position = esp.id_employee_salon_position
  INNER JOIN service s ON es.id_service = s.id_service
  INNER JOIN employee e ON esp.id_employee = e.id_employee
WHERE
  s.name LIKE 'Окрашивание%'
;

-- вычисление суммарной выручки с клиента в разрезе по датам
SELECT
  c.last_name,
  c.first_name,
  cv.date,
  SUM(es.cost) amount
FROM
  client_visit cv
  INNER JOIN client c on cv.id_client = c.id_client
  INNER JOIN client_visit_service cvs on cv.id_client_visit = cvs.id_client_visit
  INNER JOIN employee_service es ON cvs.id_employee_service = es.id_employee_service
GROUP BY c.id_client, c.last_name, c.first_name, cv.date
;

-- вычисление количества посещений клиента в 2020 году в разрезе по месяцам
SELECT
  c.last_name,
  c.first_name,
  DATE_PART('month', cv.date) visit_month,
  COUNT(cv.id_client_visit) visit_count
FROM
  client_visit cv
  INNER JOIN client c on cv.id_client = c.id_client
WHERE DATE_PART('year', cv.date) = 2020
GROUP BY c.id_client, c.last_name, c.first_name, DATE_PART('month', cv.date)
ORDER BY c.last_name, visit_month
;

-- 8. SELECT GROUP BY + HAVING
-- рейтинг наиболее посещаемых месяцев по клиентам
SELECT
  c.last_name,
  c.first_name,
  DATE_PART('month', cv.date) visit_month,
  COUNT(cv.id_client_visit) visit_count
FROM
  client_visit cv
  INNER JOIN client c on cv.id_client = c.id_client
WHERE DATE_PART('year', cv.date) = 2020
GROUP BY c.id_client, c.last_name, c.first_name, visit_month
HAVING COUNT(cv.id_client_visit) > 1
ORDER BY visit_count DESC, c.last_name
;

-- рейтинг выручки по месяцам и клиентам, у которых затраты превышают 1500
SELECT
  c.last_name,
  c.first_name,
  cv.date,
  SUM(es.cost) amount
FROM
  client_visit cv
  INNER JOIN client c on cv.id_client = c.id_client
  INNER JOIN client_visit_service cvs on cv.id_client_visit = cvs.id_client_visit
  INNER JOIN employee_service es ON cvs.id_employee_service = es.id_employee_service
GROUP BY c.id_client, c.last_name, c.first_name, cv.date
HAVING SUM(es.cost) > 1500
ORDER BY amount DESC
;

-- рейтинг мастеров по количестку оказанных услуг
SELECT
  e.last_name,
  e.first_name,
  COUNT(cvs.id_client_visit_service) services_count
FROM
  client_visit_service cvs
  INNER JOIN employee_service es ON cvs.id_employee_service = es.id_employee_service
  INNER JOIN employee_salon_position esp ON es.id_employee_salon_position = esp.id_employee_salon_position
  INNER JOIN employee e ON esp.id_employee = e.id_employee
GROUP BY e.id_employee, e.last_name, e.first_name
HAVING COUNT(cvs.id_client_visit_service) > 5
ORDER BY services_count DESC
;

-- 9. SELECT JOIN
-- список салонов, где оказывают услугу - Стрижка
SELECT DISTINCT
  s.city,
  s.address
FROM employee_salon_position esp
  INNER JOIN salon s ON esp.id_salon = s.id_salon
  LEFT JOIN (
    SELECT
      es.id_employee_salon_position,
      sv.name
    FROM
      employee_service es
      INNER JOIN service sv ON es.id_service = sv.id_service
    WHERE
      sv.name = 'Стрижка'
  ) ss ON ss.id_employee_salon_position = esp.id_employee_salon_position
WHERE
  ss.name IS NULL
;

-- список салонов, где оказывают услугу - Стрижка с ипользованием RIGHT OUTER JOIN
SELECT DISTINCT
  s.city,
  s.address
FROM
  employee_service es
  INNER JOIN service sv ON es.id_service = sv.id_service
  RIGHT OUTER JOIN employee_salon_position esp ON es.id_employee_salon_position = esp.id_employee_salon_position
  INNER JOIN salon s ON esp.id_salon = s.id_salon
WHERE
  es.id_employee_service  IS NULL
  AND sv.name = 'Стрижка'
;

-- список записей клиентов на услугу - Стрижка с 1 марта 2020 года до обеда
SELECT
  c.last_name,
  c.first_name,
  cv.date,
  cvs.scheduled_start_time,
  s.name
FROM
  client c
  LEFT JOIN client_visit cv ON cv.id_client = c.id_client
  LEFT JOIN client_visit_service cvs ON cv.id_client_visit = cvs.id_client_visit
  LEFT JOIN employee_service es ON cvs.id_employee_service = es.id_employee_service
  LEFT JOIN service s ON es.id_service = s.id_service
WHERE
  cv.date >= '2020-03-01'
  AND cvs.scheduled_start_time < '12:00'
  AND s.name = 'Стрижка'
;

-- все визиты клиентов с 1 марта 2020 года
SELECT
  c.last_name,
  c.first_name,
  cv.date
FROM
  client c
  FULL OUTER JOIN client_visit cv ON c.id_client = cv.id_client AND cv.date >= '2020-03-01'
;

-- 10. Подзапросы
-- список всех записей клиентов на маникюр по салонам
SELECT
  cv.date,
  cvs.scheduled_start_time,
  e.last_name,
  e.first_name,
  sl.city,
  sl.address
FROM
  client_visit cv
  INNER JOIN client_visit_service cvs ON cv.id_client_visit = cvs.id_client_visit
  INNER JOIN employee_service es ON cvs.id_employee_service = es.id_employee_service
  INNER JOIN employee_salon_position esp ON es.id_employee_salon_position = esp.id_employee_salon_position
  INNER JOIN employee e ON esp.id_employee = e.id_employee
  INNER JOIN salon sl ON cv.id_salon = sl.id_salon
WHERE
  es.id_service IN (
    SELECT s.id_service
    FROM service s
    WHERE s.name LIKE 'Маникюр%'
  )
;

-- рейтинг клиентов по затратам по месяцам
SELECT
  c.last_name,
  c.first_name,
  cv.date,
  (
    SELECT
      SUM(es.cost)
    FROM
      client_visit_service cvs
      INNER JOIN employee_service es ON cvs.id_employee_service = es.id_employee_service
    WHERE
      cvs.id_client_visit = cv.id_client_visit
  ) amount
FROM
  client_visit cv
  INNER JOIN client c ON cv.id_client = c.id_client
ORDER BY
  cv.date, amount DESC
;