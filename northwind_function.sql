-- Exemplos de funcoes para o banco Northwind.
-- Execute depois de northwind.sql e antes dos demais objetos do banco.
-- Funcoes retornam valores ou conjuntos de linhas e podem ser usadas em SELECT.

-- 1) Calcula o valor liquido de um pedido, considerando desconto.
-- Exemplo: SELECT fn_total_pedido(10248);
CREATE OR REPLACE FUNCTION fn_total_pedido(p_order_id smallint)
RETURNS numeric(12, 2)
LANGUAGE sql
STABLE
AS $$
    SELECT COALESCE(
        ROUND(SUM(unit_price * quantity * (1.0 - discount))::numeric, 2),
        0.00
    )
    FROM order_details
    WHERE order_id = p_order_id;
$$;

-- 2) Calcula quanto um cliente ja gerou em receitas.
-- Exemplo: SELECT fn_total_receita_cliente('ALFKI');
CREATE OR REPLACE FUNCTION fn_total_receita_cliente(p_customer_id character varying)
RETURNS numeric(14, 2)
LANGUAGE sql
STABLE
AS $$
    SELECT COALESCE(
        ROUND(SUM(od.unit_price * od.quantity * (1.0 - od.discount))::numeric, 2),
        0.00
    )
    FROM orders o
    JOIN order_details od ON od.order_id = o.order_id
    WHERE o.customer_id = p_customer_id;
$$;

-- 3) Lista produtos que atingiram ou ficaram abaixo do estoque minimo.
-- Exemplo: SELECT * FROM fn_produtos_para_reposicao(10);
CREATE OR REPLACE FUNCTION fn_produtos_para_reposicao(p_estoque_minimo smallint)
RETURNS TABLE (
    product_id smallint,
    product_name character varying,
    units_in_stock smallint,
    reorder_level smallint
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        p.product_id,
        p.product_name,
        p.units_in_stock,
        p.reorder_level
    FROM products p
    WHERE p.discontinued = 0
      AND COALESCE(p.units_in_stock, 0) <= p_estoque_minimo
    ORDER BY COALESCE(p.units_in_stock, 0), p.product_name;
$$;
