-- Criação das tabelas usando PostgreSQL (pgAdmin 4):

CREATE TABLE TB_VENDEDOR(
	CODIGO_VENDEDOR INTEGER PRIMARY KEY,
	NOME_VENDEDOR VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE TB_PRODUTO(
	CODIGO_PRODUTO INTEGER PRIMARY KEY,
	DESCRICAO_PRODUTO VARCHAR(50) UNIQUE NOT NULL,
	VALOR_UNITARIO INTEGER
)

CREATE TABLE TB_ITEM_PEDIDO(
	CODIGO_ITEM_PEDIDO SERIAL PRIMARY KEY,
	CODIGO_PEDIDO INTEGER NOT NULL,
	CODIGO_VENDEDOR INTEGER NOT NULL,
	CODIGO_PRODUTO INTEGER NOT NULL,
	QTD_ITENS INTEGER NOT NULL,
	VALOR_VENDA INTEGER NOT NULL	
)

CREATE TABLE TB_PEDIDO(
	CODIGO_PEDIDO SERIAL PRIMARY KEY,
	CODIGO_VENDEDOR INTEGER NOT NULL,
	DATA_VENDA DATE NOT NULL,
	QTD_ITENS INTEGER NOT NULL,
	VALOR_VENDA INTEGER NOT NULL	
)

INSERT INTO TB_VENDEDOR(CODIGO_VENDEDOR, NOME_VENDEDOR)
VALUES
(1001, 'Maria'),
(1003, 'Jose'),
(1004, 'Joao')

INSERT INTO TB_PRODUTO(CODIGO_PRODUTO, DESCRICAO_PRODUTO, VALOR_UNITARIO)
VALUES
(3004, 'PRODUTO 1', 600),
(3005, 'PRODUTO 2', 450),
(3006, 'PRODUTO 3', 700),
(3007, 'PRODUTO 4', 50)


INSERT INTO TB_ITEM_PEDIDO(CODIGO_PEDIDO, CODIGO_VENDEDOR, CODIGO_PRODUTO, QTD_ITENS, VALOR_VENDA)
VALUES
(1,1001,3005,5,2250),
(1,1001,3006,16,11200),
(2,1003,3006,5,3750),
(2,1003,3005,11,4950),
(2,1003,3004,1,600),
(3,1004,3004,15,9000),
(3,1004,3007,3,150),
(4,1004,3005,8,3600),
(5,1003,3004,1,600),
(5,1003,3005,2,900),
(6,1001,3005,4,1800),
(6,1001,3004,5,3000),
(6,1001,3007,4,200),
(7,1003,3006,2,1400),
(7,1003,3005,1,450),
(8,1004,3004,7,4200),
(8,1004,3005,4,1800),
(9,1004,3007,6,300),
(10,1004,3004,2,1400),
(10,1004,3007,1,80)

INSERT INTO TB_PEDIDO(CODIGO_VENDEDOR, DATA_VENDA, QTD_ITENS, VALOR_VENDA)
VALUES
(1001,'2017-10-02',21,13450),
(1003,'2017-10-10',17,9300),
(1004,'2017-11-22',18,9150),
(1004,'2017-11-27',8,3600),
(1003,'2017-12-04',3,1500),
(1001,'2017-12-12',13,5000),
(1003,'2017-12-16',3,1850),
(1004,'2017-12-20',11,6000),
(1004,'2017-12-28',6,300),
(1004,'2017-02-01',3,1480),
(1001,'2017-02-04',6,1320),
(1003,'2017-02-12',17,11550)

-- 1) Atualize na tabela TB_Produto o valor unitário de cada produto a partir da tabela item de pedido, considerando um ajuste de mais 8% em cada valor. 

-- Em uma primeira analise apenas foi adicionado 2 colunas na tabela TB_ITEM_PEDIDO para observar as diferenças de valores antes da atualização na tabela TB_Produto 

SELECT TB_ITEM_PEDIDO.*, DESCRICAO_PRODUTO, (VALOR_UNITARIO * 1.08) AS REAJUSTE_PRODUTO, ((VALOR_UNITARIO * 1.08) * QTD_ITENS) AS REAJUSTE_VALOR_VENDA FROM TB_ITEM_PEDIDO
INNER JOIN TB_PRODUTO
ON TB_ITEM_PEDIDO.CODIGO_PRODUTO = TB_PRODUTO.CODIGO_PRODUTO

-- Em seguida foi feita a alteração do valor unitário com base nos valores da tabela TB_ITEM_PEDIDO:

UPDATE TB_PRODUTO
SET VALOR_UNITARIO = ((TB_ITEM_PEDIDO.VALOR_VENDA/TB_ITEM_PEDIDO.QTD_ITENS) * 1.08)
FROM TB_ITEM_PEDIDO
WHERE TB_ITEM_PEDIDO.CODIGO_PRODUTO = TB_PRODUTO.CODIGO_PRODUTO

-- 2) Criar um ranking com o valor de vendas decrescente em cada mês. Retorne o ano/mês da venda e o valor total de cada mês.


SELECT
	RANK () OVER (ORDER BY SUM(Valor_Venda) DESC),
	SUM(Valor_Venda) AS Valor_Total_Mes, to_char(Data_Venda, 'Month') AS Mes, to_char(Data_Venda, 'YYYY') as Ano
FROM tb_pedido
GROUP BY Mes, Ano

-- 3) Criar uma tabela temporária contendo o nome do vendedor, a quantidade de pedidos, a quantidade total de itens, a quantidade de itens vendidos entre o dia 12/12/2017 e 28/12/2017, a data da primeira venda (no formato DD/MM/YYYY) e a data da última venda (no formato DD/MM/YYYY). É esperado somente uma linha por vendedor.

CREATE TEMPORARY TABLE Tabela_Temporaria_01
(
	nome_vendedor VARCHAR(100),
	total_pedidos int,
	total_itens int,
	itens_periodo_dezembro int,
	primeira_venda date,
	ultima_venda date
)

select * from Tabela_Temporaria_01

INSERT INTO Tabela_Temporaria_01(nome_vendedor, total_pedidos, total_itens, itens_periodo_dezembro, primeira_venda, ultima_venda)

SELECT vendas_total.nome_vendedor, total_pedidos, total_itens, itens_periodo_dezembro, primeira_venda, ultima_venda FROM (
SELECT nome_vendedor, COUNT(*) as total_pedidos, SUM(qtd_itens) AS total_itens FROM tb_vendedor
INNER JOIN tb_pedido
ON tb_vendedor.codigo_vendedor = tb_pedido.codigo_vendedor
GROUP BY nome_vendedor) AS vendas_total

INNER JOIN

(SELECT nome_vendedor, SUM(qtd_itens) as itens_periodo_dezembro  FROM tb_vendedor
INNER JOIN tb_pedido
ON tb_pedido.codigo_vendedor = tb_vendedor.codigo_vendedor
WHERE data_venda BETWEEN '2017-12-12' AND '2017-12-28'
GROUP BY nome_vendedor) AS vendas_periodo_dezembro

ON vendas_total.nome_vendedor = vendas_periodo_dezembro.nome_vendedor

INNER JOIN

(SELECT nome_vendedor, MIN(data_venda) AS primeira_venda, MAX(data_venda) AS ultima_venda FROM tb_vendedor
INNER JOIN tb_pedido
ON tb_vendedor.codigo_vendedor = tb_pedido.codigo_vendedor
GROUP BY nome_vendedor) AS datas_vendas

ON vendas_total.nome_vendedor = datas_vendas.nome_vendedor

SELECT nome_vendedor, total_pedidos, total_itens, itens_periodo_dezembro, to_char(primeira_venda, 'DD/MM/YYYY') AS primeira_venda, to_char(ultima_venda, 'DD/MM/YYYY') AS ultima_venda from Tabela_Temporaria_01


-- 4) Qual o produto mais vendido (em quantidade) de cada vendedor? Mostre em uma tabela o nome do vendedor, a descrição do produto, a quantidade e o valor unitário do produto. Salvar o resultado em uma tabela temporária.

CREATE TEMPORARY TABLE Tabela_Temporaria_02
(
	nome_vendedor VARCHAR(50),
	descricao_produto VARCHAR(50),
	quantidade_produtos int,
	valor_unitario int
)

select * from Tabela_Temporaria_02

INSERT INTO Tabela_Temporaria_02(nome_vendedor, descricao_produto, quantidade_produtos, valor_unitario)

SELECT nome_vendedor, descricao_produto, quantidade_produtos, valor_unitario FROM(
	
	SELECT nome_vendedor, descricao_produto, COUNT(tb_item_pedido.codigo_produto) AS quantidade_produtos, valor_unitario,
		ROW_NUMBER () OVER (PARTITION BY nome_vendedor ORDER BY COUNT(tb_item_pedido.codigo_produto) DESC) AS t
		FROM tb_item_pedido
	INNER JOIN tb_vendedor
	ON tb_item_pedido.codigo_vendedor = tb_vendedor.codigo_vendedor
	INNER JOIN tb_produto
	ON tb_item_pedido.codigo_produto = tb_produto.codigo_produto
	GROUP BY nome_vendedor, descricao_produto, valor_unitario
	) x
	
WHERE x.t = 1
ORDER BY quantidade_produtos DESC

SELECT * FROM Tabela_Temporaria_02





