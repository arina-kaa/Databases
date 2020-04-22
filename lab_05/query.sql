-- 0. Создать таблицы
CREATE TABLE IF NOT EXISTS booking (
  id_booking serial PRIMARY KEY,
  id_client int NOT NULL,
  booking_date date NOT NULL
);

CREATE TABLE IF NOT EXISTS client (
  id_client serial PRIMARY KEY,
  name varchar (50) NOT NULL,
  phone varchar (25) NOT NULL
);

CREATE TABLE IF NOT EXISTS hotel (
  id_hotel serial PRIMARY KEY,
  name varchar (50) NOT NULL,
  stars smallint NULL
);

CREATE TABLE IF NOT EXISTS room (
  id_room serial PRIMARY KEY,
  id_hotel int NOT NULL,
  id_room_category int NOT NULL,
  number varchar (10) NOT NULL,
  price numeric(7, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS room_category (
  id_room_category serial PRIMARY KEY,
  name varchar (50) NOT NULL,
  square smallint NOT NULL
);

CREATE TABLE IF NOT EXISTS room_in_booking (
  id_room_in_booking serial PRIMARY KEY,
  id_booking int NOT NULL,
  id_room int NOT NULL,
  checkin_date date NOT NULL,
  checkout_date date NOT NULL
);

-- Испорт данных
-- После импорта выполнить:
SELECT SETVAL('booking_id_booking_seq', (SELECT MAX(id_booking) FROM booking));
SELECT SETVAL('client_id_client_seq', (SELECT MAX(id_client) FROM client));
SELECT SETVAL('hotel_id_hotel_seq', (SELECT MAX(id_hotel) FROM hotel));
SELECT SETVAL('room_id_room_seq', (SELECT MAX(id_room) FROM room));
SELECT SETVAL('room_category_id_room_category_seq', (SELECT MAX(id_room_category) FROM room_category));
SELECT SETVAL('room_in_booking_id_room_in_booking_seq', (SELECT MAX(id_room_in_booking) FROM room_in_booking));

-- 1. Добавить внешние ключи
ALTER TABLE booking
ADD CONSTRAINT fk_booking_client FOREIGN KEY (id_client) REFERENCES client (id_client);

ALTER TABLE room
ADD CONSTRAINT fk_room_hotel FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel);

ALTER TABLE room
ADD CONSTRAINT fk_room_room_category FOREIGN KEY (id_room_category) REFERENCES room_category (id_room_category);

ALTER TABLE room_in_booking
ADD CONSTRAINT fk_room_in_booking_booking FOREIGN KEY (id_booking) REFERENCES booking (id_booking);

ALTER TABLE room_in_booking
ADD CONSTRAINT fk_room_in_booking_room FOREIGN KEY (id_room) REFERENCES room (id_room);

-- 2. Выдать информацию о клиентах гостиницы “Космос”, проживающих в номерах
-- категории “Люкс” на 1 апреля 2019 г.
SELECT c.*
FROM
  room_in_booking rib
  INNER JOIN room r ON rib.id_room = r.id_room
  INNER JOIN room_category rc ON r.id_room_category = rc.id_room_category
  INNER JOIN hotel h ON r.id_hotel = h.id_hotel
  INNER JOIN booking b ON rib.id_booking = b.id_booking
  INNER JOIN client c ON b.id_client = c.id_client
WHERE
  h.name = 'Космос'
  AND rc.name = 'Люкс'
  AND rib.checkin_date <= '2019-04-01'
  AND rib.checkout_date > '2019-04-01'
;

-- 3. Дать список свободных номеров всех гостиниц на 22 апреля.
SELECT
  h.name hotel_name,
  h.stars hotel_stars,
  r.number room_number,
  rc.name room_category,
  r.price
FROM
  hotel h
  INNER JOIN room r ON h.id_hotel = r.id_hotel
  INNER JOIN room_category rc ON r.id_room_category = rc.id_room_category
WHERE
  r.id_room NOT IN (
    SELECT rib.id_room
    FROM
      room_in_booking rib
    WHERE
      rib.checkin_date <= '2019-04-22'
      AND rib.checkout_date > '2019-04-22'
  )
;

-- 4. Дать количество проживающих в гостинице “Космос” на 23 марта по каждой
-- категории номеров
SELECT
  rc.name room_category,
  COUNT(DISTINCT c.id_client) clients_count
FROM
  room_in_booking rib
  INNER JOIN room r ON rib.id_room = r.id_room
  INNER JOIN room_category rc ON r.id_room_category = rc.id_room_category
  INNER JOIN hotel h ON r.id_hotel = h.id_hotel
  INNER JOIN booking b ON rib.id_booking = b.id_booking
  INNER JOIN client c ON b.id_client = c.id_client
WHERE
  h.name = 'Космос'
  AND rib.checkin_date <= '2019-03-23'
  AND rib.checkout_date > '2019-03-23'
GROUP BY rc.name
;

-- 5. Дать список последних проживавших клиентов по всем комнатам гостиницы
-- “Космос”, выехавшим в апреле с указанием даты выезда.
SELECT
  h.name hotel_name,
  h.stars hotel_stars,
  r.number room_number,
  rc.name room_category,
  c.name last_client_name,
  c.phone last_client_phone
FROM
  hotel h
  INNER JOIN room r ON h.id_hotel = r.id_hotel
  INNER JOIN room_category rc ON r.id_room_category = rc.id_room_category
  INNER JOIN room_in_booking rib ON rib.id_room_in_booking = (
    SELECT
      trib.id_room_in_booking
    FROM room_in_booking trib
    WHERE
      trib.id_room = r.id_room
      AND TO_CHAR(trib.checkout_date, 'YYYY-MM') = '2019-04'
    ORDER BY trib.checkout_date DESC
    LIMIT 1
  )
  INNER JOIN booking b ON rib.id_booking = b.id_booking
  INNER JOIN client c ON b.id_client = c.id_client
WHERE
  h.name = 'Космос'
;

-- 6. Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам
-- комнат категории “Бизнес”, которые заселились 10 мая
UPDATE
  room_in_booking
SET checkout_date = checkout_date + INTERVAL '2 day'
WHERE
  id_room_in_booking IN (
    SELECT
      rib.id_room_in_booking
    FROM
      room_in_booking rib
      INNER JOIN room r ON rib.id_room = r.id_room
      INNER JOIN room_category rc ON r.id_room_category = rc.id_room_category
      INNER JOIN hotel h ON r.id_hotel = h.id_hotel
      INNER JOIN booking b ON rib.id_booking = b.id_booking
      INNER JOIN client c ON b.id_client = c.id_client
    WHERE
      h.name = 'Космос'
      AND rc.name = 'Бизнес'
      AND rib.checkin_date = '2019-05-10'
  )
;

-- 7. Найти все "пересекающиеся" варианты проживания. Правильное состояние: не
-- может быть забронирован один номер на одну дату несколько раз, т.к. нельзя
-- заселиться нескольким клиентам в один номер. Записи в таблице
-- room_in_booking с id_room_in_booking = 5 и 2154 являются примером
-- неправильного состояния, которые необходимо найти. Результирующий кортеж
-- выборки должен содержать информацию о двух конфликтующих номерах.
SELECT
  rib.id_room_in_booking,
  rib.id_booking,
  rib.id_room,
  rib.checkin_date,
  rib.checkout_date,
  rib2.id_room_in_booking,
  rib2.id_booking,
  rib2.id_room,
  rib2.checkin_date,
  rib2.checkout_date
FROM
  room_in_booking rib
  INNER JOIN room_in_booking rib2 ON (
    rib.id_room = rib2.id_room
    AND rib.id_room_in_booking <> rib2.id_room_in_booking
    AND rib2.checkin_date BETWEEN rib.checkin_date AND rib.checkout_date + INTERVAL '-1' DAY
  )
;

-- 8. Создать бронирование в транзакции.
BEGIN;

INSERT INTO client (name, phone)
VALUES ('Яворивский Ефрем Максимович', '7(553)676-48-34');

INSERT INTO booking (id_client, booking_date)
VALUES ((SELECT id_client FROM client ORDER BY 1 DESC LIMIT 1), NOW());

INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
VALUES ((SELECT booking.id_booking FROM booking ORDER BY 1 DESC LIMIT 1), 10, '2020-04-15', '2020-04-22');

-- ROLLBACK;
COMMIT;

-- 9. Добавить необходимые индексы для всех таблиц.
CREATE INDEX idx_client ON booking(id_client);
CREATE INDEX idx_phone ON client(phone);
CREATE INDEX idx_hotel ON room(id_hotel);
CREATE INDEX idx_room_category ON room(id_room_category);
CREATE INDEX idx_booking ON room_in_booking(id_booking);
CREATE INDEX idx_room ON room_in_booking(id_room);
CREATE INDEX idx_checkin_checkout ON room_in_booking(checkin_date, checkout_date);