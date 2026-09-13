-- Exemplos de procedures para o banco Northwind.
-- Execute depois de northwind.sql.
-- Procedures executam comandos; por isso nao retornam linhas como uma funcao.

-- 1) Reajusta os precos de uma categoria por percentual.
-- Exemplo: CALL sp_reajustar_precos_categoria(1, 5);
CREATE OR REPLACE PROCEDURE sp_reajustar_precos_categoria(
    p_category_id smallint,
    p_percentual numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_percentual <= -100 THEN
        RAISE EXCEPTION 'O percentual deve ser maior que -100';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM categories WHERE category_id = p_category_id
    ) THEN
        RAISE EXCEPTION 'Categoria % nao existe', p_category_id;
    END IF;

    UPDATE products
    SET unit_price = ROUND((unit_price * (1 + p_percentual / 100))::numeric, 2)::real
    WHERE category_id = p_category_id
      AND unit_price IS NOT NULL;
END;
$$;

-- 2) Faz uma reposicao controlada de estoque.
-- O limite impede que uma chamada acidental altere muitos produtos.
-- Exemplo: CALL sp_repor_estoque(10, 25);
CREATE OR REPLACE PROCEDURE sp_repor_estoque(
    p_product_id smallint,
    p_quantidade smallint
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_quantidade <= 0 THEN
        RAISE EXCEPTION 'A quantidade de reposicao deve ser positiva';
    END IF;

    UPDATE products
    SET units_in_stock = COALESCE(units_in_stock, 0) + p_quantidade,
        units_on_order = GREATEST(COALESCE(units_on_order, 0) - p_quantidade, 0)
    WHERE product_id = p_product_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto % nao existe', p_product_id;
    END IF;
END;
$$;

-- 3) Marca um produto como descontinuado sem apaga-lo do historico.
-- Exemplo: CALL sp_descontinuar_produto(10);
CREATE OR REPLACE PROCEDURE sp_descontinuar_produto(
    p_product_id smallint
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE products
    SET discontinued = 1
    WHERE product_id = p_product_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto % nao existe', p_product_id;
    END IF;
END;
$$;
