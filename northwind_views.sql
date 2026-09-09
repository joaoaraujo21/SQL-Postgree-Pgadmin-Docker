--Qual foi o total de receitas no ano de 1997?

--Perfeita. Melhor performance.
CREATE VIEW CREATE VIEW vw_total_receita_1997_view AS
SELECT 
	ROUND(CAST(SUM((od.unit_price) * od.quantity * (1.0 - od.discount)) AS NUMERIC), 2) AS Receita
FROM order_details od
JOIN orders o on od.order_id = o.order_id
WHERE o.order_date >= '1997-01-01' 
  AND o.order_date < '1998-01-01';


-- Faça uma análise de crescimento mensal e o cálculo de acumulado no ano

CREATE VIEW vw_receita_mensal_acumulada
WITH RECEITA_MENSAL AS (
	SELECT
		EXTRACT( YEAR FROM o.order_date) AS Ano
		,EXTRACT( MONTH FROM o.order_date) AS Mes
		,ROUND(CAST(SUM((od.unit_price) * od.quantity * (1.0 - od.discount)) AS NUMERIC), 2) AS Receita_Mensal
	FROM 
		orders o
	LEFT JOIN order_details od ON o.order_id = od.order_id
	GROUP BY 
		EXTRACT( YEAR FROM o.order_date),
		EXTRACT( MONTH FROM o.order_date)
),
RECEITA_ACUMULADA AS (
	SELECT
		Ano
		,Mes
		,Receita_Mensal
		,SUM(Receita_Mensal) OVER (PARTITION BY Ano ORDER BY Mes) AS Receita_Acumulada
	FROM 
		RECEITA_MENSAL
)
	SELECT 
		Ano
		,Mes
		,Receita_Mensal
		,Receita_Mensal - LAG(Receita_Mensal) OVER (PARTITION BY Ano ORDER BY Mes) AS Diferenca_Mensal
		,Receita_Acumulada
		,TO_CHAR(
			(Receita_Mensal - LAG(Receita_Mensal) OVER (PARTITION BY Ano Order BY Mes)) 
			/ LAG(Receita_Mensal) OVER (PARTITION BY Ano Order BY Mes) * 100, 
			'FM9999990.00') || '%' AS Percentual_Mudanca_Mensal
	FROM 
		RECEITA_ACUMULADA
	ORDER BY Ano, Mes;


-- Qual é o valor total que cada cliente já pagou até agora? 

CREATE VIEW vw_total_receita_por_cliente AS
SELECT 
    customers.company_name, 
    ROUND(CAST(SUM(order_details.unit_price * order_details.quantity * (1.0 - order_details.discount))AS NUMERIC),2) AS total
FROM 
    customers
INNER JOIN 
    orders ON customers.customer_id = orders.customer_id
INNER JOIN 
    order_details ON order_details.order_id = orders.order_id
GROUP BY 
    customers.company_name
ORDER BY 
    total DESC;


--Separe os clientes em 5 grupos de acordo com o valor pago por cliente

CREATE VIEW vw_total_receita_por_grupo_clientes AS
SELECT 
customers.company_name, 
SUM(order_details.unit_price * order_details.quantity * (1.0 - order_details.discount)) AS total,
NTILE(5) OVER (ORDER BY SUM(order_details.unit_price * order_details.quantity * (1.0 - order_details.discount)) DESC) AS group_number
FROM 
    customers
INNER JOIN 
    orders ON customers.customer_id = orders.customer_id
INNER JOIN 
    order_details ON order_details.order_id = orders.order_id
GROUP BY 
    customers.company_name
ORDER BY 
    total DESC;


--Agora somente os clientes que estão nos grupos 3, 4 e 5 para que seja feita uma análise de Marketing especial com eles

CREATE VIEW vw_clientes_para_marketing AS
WITH clientes_para_marketing AS (
    SELECT 
    customers.company_name, 
    SUM(order_details.unit_price * order_details.quantity * (1.0 - order_details.discount)) AS total,
    NTILE(5) OVER (ORDER BY SUM(order_details.unit_price * order_details.quantity * (1.0 - order_details.discount)) DESC) AS group_number
FROM 
    customers
INNER JOIN 
    orders ON customers.customer_id = orders.customer_id
INNER JOIN 
    order_details ON order_details.order_id = orders.order_id
GROUP BY 
    customers.company_name
ORDER BY 
    total DESC
)

SELECT *
FROM clientes_para_marketing
WHERE group_number >= 3;