-- Indices adicionais para o banco Northwind.
-- As chaves primarias do northwind.sql ja criam seus proprios indices.
-- Execute este arquivo depois de northwind.sql e antes das views analiticas.

-- Filtro usado na analise de receitas por periodo.
CREATE INDEX IF NOT EXISTS idx_orders_order_date
    ON orders (order_date);

-- Chaves estrangeiras usadas nos relacionamentos e nos joins.
CREATE INDEX IF NOT EXISTS idx_orders_customer_id
    ON orders (customer_id);

CREATE INDEX IF NOT EXISTS idx_orders_employee_id
    ON orders (employee_id);

CREATE INDEX IF NOT EXISTS idx_orders_ship_via
    ON orders (ship_via);

CREATE INDEX IF NOT EXISTS idx_order_details_product_id
    ON order_details (product_id);

CREATE INDEX IF NOT EXISTS idx_products_category_id
    ON products (category_id);

CREATE INDEX IF NOT EXISTS idx_products_supplier_id
    ON products (supplier_id);

CREATE INDEX IF NOT EXISTS idx_territories_region_id
    ON territories (region_id);

CREATE INDEX IF NOT EXISTS idx_employee_territories_territory_id
    ON employee_territories (territory_id);

CREATE INDEX IF NOT EXISTS idx_customer_customer_demo_type_id
    ON customer_customer_demo (customer_type_id);

CREATE INDEX IF NOT EXISTS idx_employees_reports_to
    ON employees (reports_to);

-- Atualiza as estatisticas usadas pelo planejador de consultas.
ANALYZE categories;
ANALYZE customer_customer_demo;
ANALYZE customer_demographics;
ANALYZE customers;
ANALYZE employees;
ANALYZE employee_territories;
ANALYZE order_details;
ANALYZE orders;
ANALYZE products;
ANALYZE region;
ANALYZE shippers;
ANALYZE suppliers;
ANALYZE territories;
ANALYZE us_states;
