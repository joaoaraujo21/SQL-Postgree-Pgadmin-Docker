-- Exemplos de triggers para o banco Northwind.
-- Execute depois de northwind.sql.

-- 1) Impede estoque, quantidade e desconto invalidos nos itens dos pedidos.
CREATE OR REPLACE FUNCTION fn_validar_item_pedido()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.quantity <= 0 THEN
        RAISE EXCEPTION 'A quantidade do item deve ser positiva';
    END IF;

    IF NEW.unit_price < 0 THEN
        RAISE EXCEPTION 'O preco unitario nao pode ser negativo';
    END IF;

    IF NEW.discount < 0 OR NEW.discount > 1 THEN
        RAISE EXCEPTION 'O desconto deve estar entre 0 e 1';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validar_item_pedido ON order_details;
CREATE TRIGGER trg_validar_item_pedido
BEFORE INSERT OR UPDATE ON order_details
FOR EACH ROW
EXECUTE FUNCTION fn_validar_item_pedido();

-- 2) Nao permite vender produtos descontinuados.
CREATE OR REPLACE FUNCTION fn_bloquear_produto_descontinuado()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM products
        WHERE product_id = NEW.product_id
          AND discontinued = 1
    ) THEN
        RAISE EXCEPTION 'O produto % esta descontinuado', NEW.product_id;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_bloquear_produto_descontinuado ON order_details;
CREATE TRIGGER trg_bloquear_produto_descontinuado
BEFORE INSERT OR UPDATE ON order_details
FOR EACH ROW
EXECUTE FUNCTION fn_bloquear_produto_descontinuado();

-- 3) Mantem historico das alteracoes de preco dos produtos.
CREATE TABLE IF NOT EXISTS product_price_history (
    history_id bigserial PRIMARY KEY,
    product_id smallint NOT NULL,
    old_unit_price real,
    new_unit_price real,
    changed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_registrar_alteracao_preco()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.unit_price IS DISTINCT FROM OLD.unit_price THEN
        INSERT INTO product_price_history (product_id, old_unit_price, new_unit_price)
        VALUES (OLD.product_id, OLD.unit_price, NEW.unit_price);
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_registrar_alteracao_preco ON products;
CREATE TRIGGER trg_registrar_alteracao_preco
AFTER UPDATE OF unit_price ON products
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_alteracao_preco();
