-- Exemplos de materialized views para o banco Northwind.
-- Execute depois de northwind.sql e, de preferencia, depois dos indices.
-- Elas armazenam o resultado fisicamente e precisam de REFRESH para atualizar.

-- 1) Receita consolidada por produto e categoria.
-- E adequada para dashboards porque evita recalcular os joins e a soma a cada leitura.
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_receita_por_produto AS
SELECT
    p.product_id,
    p.product_name,
    c.category_id,
    c.category_name,
    COUNT(DISTINCT od.order_id) AS quantidade_pedidos,
    SUM(od.quantity) AS unidades_vendidas,
    ROUND(SUM(od.unit_price * od.quantity * (1.0 - od.discount))::numeric, 2) AS receita_total
FROM products p
JOIN categories c ON c.category_id = p.category_id
JOIN order_details od ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name, c.category_id, c.category_name;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_receita_por_produto_id
    ON mv_receita_por_produto (product_id);

-- 2) Receita mensal por ano.
-- E adequada para relatorios historicos repetidos e analises de tendencia.
-- Uma view normal faria a agregacao novamente em cada consulta.
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_receita_mensal AS
SELECT
    EXTRACT(YEAR FROM o.order_date)::integer AS ano,
    EXTRACT(MONTH FROM o.order_date)::integer AS mes,
    COUNT(DISTINCT o.order_id) AS quantidade_pedidos,
    SUM(od.quantity) AS unidades_vendidas,
    ROUND(SUM(od.unit_price * od.quantity * (1.0 - od.discount))::numeric, 2) AS receita_total
FROM orders o
JOIN order_details od ON od.order_id = o.order_id
WHERE o.order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date);

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_receita_mensal_ano_mes
    ON mv_receita_mensal (ano, mes);

-- Atualize depois de novas vendas:
-- REFRESH MATERIALIZED VIEW mv_receita_por_produto;
-- REFRESH MATERIALIZED VIEW mv_receita_mensal;
