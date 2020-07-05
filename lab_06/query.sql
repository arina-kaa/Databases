-- 0. Создать таблицы
CREATE TABLE IF NOT EXISTS company (
  id_company serial PRIMARY KEY,
  name varchar (50) NOT NULL,
  established int NOT NULL
);

CREATE TABLE IF NOT EXISTS dealer (
  id_dealer serial PRIMARY KEY,
  id_company int NOT NULL,
  name varchar (50) NOT NULL,
  phone varchar (50) NOT NULL
);

CREATE TABLE IF NOT EXISTS medicine (
  id_medicine serial PRIMARY KEY,
  name varchar (50) NOT NULL,
  cure_duration smallint NOT NULL
);

CREATE TABLE IF NOT EXISTS "order" (
  id_order serial PRIMARY KEY,
  id_production int NOT NULL,
  id_dealer int NOT NULL,
  id_pharmacy int NOT NULL,
  date date NOT NULL,
  quantity int NOT NULL
);

CREATE TABLE IF NOT EXISTS pharmacy (
  id_pharmacy serial PRIMARY KEY,
  name varchar (100) NOT NULL,
  rating float NULL
);

CREATE TABLE IF NOT EXISTS production (
  id_production serial PRIMARY KEY,
  id_company int NOT NULL,
  id_medicine int NOT NULL,
  price numeric(7, 2) NOT NULL,
  rating smallint NOT NULL
);

-- Испорт данных
-- После импорта выполнить:
SELECT SETVAL('company_id_company_seq', (SELECT MAX(id_company) FROM company));
SELECT SETVAL('dealer_id_dealer_seq', (SELECT MAX(id_dealer) FROM dealer));
SELECT SETVAL('medicine_id_medicine_seq', (SELECT MAX(id_medicine) FROM medicine));
SELECT SETVAL('order_id_order_seq', (SELECT MAX(id_order) FROM "order"));
SELECT SETVAL('pharmacy_id_pharmacy_seq', (SELECT MAX(id_pharmacy) FROM pharmacy));
SELECT SETVAL('production_id_production_seq', (SELECT MAX(id_production) FROM production));

-- 1. Добавить внешние ключи.
ALTER TABLE dealer
ADD CONSTRAINT fk_dealer_company FOREIGN KEY (id_company) REFERENCES company (id_company);

ALTER TABLE "order"
ADD CONSTRAINT fk_order_production FOREIGN KEY (id_production) REFERENCES production (id_production);

ALTER TABLE "order"
ADD CONSTRAINT fk_order_dealer FOREIGN KEY (id_dealer) REFERENCES dealer (id_dealer);

ALTER TABLE "order"
ADD CONSTRAINT fk_order_pharmacy FOREIGN KEY (id_pharmacy) REFERENCES pharmacy (id_pharmacy);

ALTER TABLE production
ADD CONSTRAINT fk_production_company FOREIGN KEY (id_company) REFERENCES company (id_company);

ALTER TABLE production
ADD CONSTRAINT fk_production_medicine FOREIGN KEY (id_medicine) REFERENCES medicine (id_medicine);

-- 2. Выдать информацию по всем заказам лекарства “Кордеон” компании “Аргус” с
-- указанием названий аптек, дат, объема заказов.
SELECT
  ph.name pharmacy,
  o.date,
  o.quantity,
  p.price,
  o.quantity * p.price total
FROM
  "order" o
  INNER JOIN production p ON o.id_production = p.id_production
  INNER JOIN company c ON p.id_company = c.id_company
  INNER JOIN medicine m ON p.id_medicine = m.id_medicine
  INNER JOIN pharmacy ph ON o.id_pharmacy = ph.id_pharmacy
WHERE
  c.name = 'Аргус'
  AND m.name = 'Кордеон'
;

-- 3. Дать список лекарств компании “Фарма”, на которые не были сделаны заказы
-- до 25 января.
SELECT
  m.name medicine,
  p.price
FROM
  company c
  INNER JOIN production p ON c.id_company = p.id_company
  INNER JOIN medicine m ON p.id_medicine = m.id_medicine
WHERE
  c.name = 'Фарма'
  AND p.id_production NOT IN (
    SELECT o.id_production
    FROM "order" o
    WHERE o.date < '2019-01-25'
  )
;

-- 4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая
-- оформила не менее 120 заказов
SELECT
  c.name company,
  MIN(p.rating) min_prod_rating,
  MAX(p.rating) max_prod_rating
FROM
  "order" o
  INNER JOIN production p ON o.id_production = p.id_production
  INNER JOIN company c ON p.id_company = c.id_company
GROUP BY c.id_company, c.name
HAVING COUNT(DISTINCT o.id_order) >= 120
;

-- 5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”.
-- Если у дилера нет заказов, в названии аптеки проставить NULL
SELECT
  d.name dealer_name,
  d.phone dealer_phone,
  r.pharmacy_name
FROM
  dealer d
  INNER JOIN company c ON d.id_company = c.id_company
  LEFT JOIN (
    SELECT
      o.id_dealer,
      ph.name pharmacy_name
    FROM
      "order" o
      INNER JOIN pharmacy ph ON o.id_pharmacy = ph.id_pharmacy
  ) r ON d.id_dealer = r.id_dealer
WHERE
  c.name = 'AstraZeneca'
;

-- 6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а
-- длительность лечения не более 7 дней
UPDATE
  production
SET price = price * 0.8
WHERE
  id_production IN (
    SELECT p.id_production
    FROM
      production p
      INNER JOIN medicine m ON p.id_medicine = m.id_medicine
    WHERE
      p.price > 3000
      AND m.cure_duration <= 7
  )
;

-- 7. Добавить необходимые индексы.
CREATE INDEX idx_company ON dealer(id_company);
CREATE INDEX idx_production ON "order"(id_production);
CREATE INDEX idx_dealer ON "order"(id_dealer);
CREATE INDEX idx_pharmacy ON "order"(id_pharmacy);
CREATE INDEX idx_date ON "order"(date);
CREATE INDEX idx_company_prod ON production(id_company);
CREATE INDEX idx_medicine ON production(id_medicine);

CREATE INDEX idx_date ON "order"(date);
CREATE INDEX idx_price ON production(price);
CREATE INDEX idx_cure_duration ON medicine(cure_duration);