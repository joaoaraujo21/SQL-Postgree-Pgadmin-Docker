-- Particionamento do Northwind
--
-- Este script cria estruturas particionadas paralelas. Ele nao substitui
-- automaticamente as tabelas atuais, pois orders possui uma PK em order_id
-- e o PostgreSQL exige que uma chave unica de tabela particionada contenha
-- a chave de particionamento.
--
-- Execute depois de northwind.sql. Depois de validar os dados, as views que
-- precisarem se beneficiar do particionamento devem consultar estas tabelas.

-- Pedidos por ano: consultas com filtro em order_date podem ignorar
-- particoes de outros anos (partition pruning).
CREATE TABLE IF NOT EXISTS orders_partitioned (
    order_id smallint NOT NULL,
    customer_id character varying(5),
    employee_id smallint,
    order_date date NOT NULL,
    required_date date,
    shipped_date date,
    ship_via smallint,
    freight real,
    ship_name character varying(40),
    ship_address character varying(60),
    ship_city character varying(15),
    ship_region character varying(15),
    ship_postal_code character varying(10),
    ship_country character varying(15)
) PARTITION BY RANGE (order_date);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'uq_orders_partitioned_order_id_date'
    ) THEN
        ALTER TABLE orders_partitioned
            ADD CONSTRAINT uq_orders_partitioned_order_id_date
            UNIQUE (order_id, order_date);
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS orders_partitioned_1996
    PARTITION OF orders_partitioned
    FOR VALUES FROM ('1996-01-01') TO ('1997-01-01');

CREATE TABLE IF NOT EXISTS orders_partitioned_1997
    PARTITION OF orders_partitioned
    FOR VALUES FROM ('1997-01-01') TO ('1998-01-01');

CREATE TABLE IF NOT EXISTS orders_partitioned_1998
    PARTITION OF orders_partitioned
    FOR VALUES FROM ('1998-01-01') TO ('1999-01-01');

-- Mantem pedidos fora das faixas conhecidas sem interromper cargas futuras.
CREATE TABLE IF NOT EXISTS orders_partitioned_default
    PARTITION OF orders_partitioned DEFAULT;

-- Os indices criados no pai sao propagados para as particoes.
CREATE INDEX IF NOT EXISTS idx_orders_partitioned_order_date
    ON orders_partitioned (order_date);

CREATE INDEX IF NOT EXISTS idx_orders_partitioned_customer_id
    ON orders_partitioned (customer_id);

-- Itens dos pedidos por faixa de order_id: reduz o volume examinado em
-- consultas que trabalham com intervalos de pedidos.
CREATE TABLE IF NOT EXISTS order_details_partitioned (
    order_id smallint NOT NULL,
    product_id smallint NOT NULL,
    unit_price real NOT NULL,
    quantity smallint NOT NULL,
    discount real NOT NULL
) PARTITION BY RANGE (order_id);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'pk_order_details_partitioned'
    ) THEN
        ALTER TABLE order_details_partitioned
            ADD CONSTRAINT pk_order_details_partitioned
            PRIMARY KEY (order_id, product_id);
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS order_details_partitioned_10248_10400
    PARTITION OF order_details_partitioned
    FOR VALUES FROM (10248) TO (10400);

CREATE TABLE IF NOT EXISTS order_details_partitioned_10400_10500
    PARTITION OF order_details_partitioned
    FOR VALUES FROM (10400) TO (10500);

CREATE TABLE IF NOT EXISTS order_details_partitioned_default
    PARTITION OF order_details_partitioned DEFAULT;

CREATE INDEX IF NOT EXISTS idx_order_details_partitioned_product_id
    ON order_details_partitioned (product_id);

-- Carga inicial das tabelas paralelas. ON CONFLICT permite executar o
-- script novamente sem duplicar os registros ja copiados.
INSERT INTO orders_partitioned
SELECT *
FROM orders
ON CONFLICT DO NOTHING;

INSERT INTO order_details_partitioned
SELECT *
FROM order_details
ON CONFLICT DO NOTHING;

ANALYZE orders_partitioned;
ANALYZE order_details_partitioned;
