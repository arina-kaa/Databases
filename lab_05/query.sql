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
  checking_date date NOT NULL,
  checkout_date date NOT NULL
);

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
  AND rib.checking_date <= '2019-04-01'
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
  LEFT JOIN room_in_booking rib ON (
    r.id_room = rib.id_room
    AND rib.checking_date <= '2019-04-22'
    AND rib.checkout_date > '2019-04-22'
  )
WHERE
  rib.id_room_in_booking IS NULL
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
  AND rib.checking_date <= '2019-03-23'
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
      MAX(trib.id_room_in_booking)
    FROM room_in_booking trib
    WHERE
      trib.id_room = r.id_room
      AND TO_CHAR(trib.checkout_date, 'YYYY-MM') = '2019-04'
  )
  INNER JOIN booking b ON rib.id_booking = b.id_booking
  INNER JOIN client c ON b.id_client = c.id_client
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
      AND rib.checking_date = '2019-05-10'
  )
;

-- 7. Найти все "пересекающиеся" варианты проживания. Правильное состояние: не
-- может быть забронирован один номер на одну дату несколько раз, т.к. нельзя
-- заселиться нескольким клиентам в один номер. Записи в таблице
-- room_in_booking с id_room_in_booking = 5 и 2154 являются примером
-- неправильного состояния, которые необходимо найти. Результирующий кортеж
-- выборки должен содержать информацию о двух конфликтующих номерах.


-- 8. Создать бронирование в транзакции.


-- 9. Добавить необходимые индексы для всех таблиц.