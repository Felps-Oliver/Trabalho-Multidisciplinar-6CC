-->Q1. Obtendo faturamento de 1 mes para tr�s, com base na data atual

SELECT SUM(valor_total_compra) AS Faturamento_Mensal
FROM COMPRA
WHERE data_compra BETWEEN (GETDATE() - 30) AND GETDATE()

-->Q2. Obtendo total de itens comprados, agrupado por consumidor

SELECT PESSOA.nome AS Consumidor,
	PESSOA.CPF AS CPF_Consumidor, 
	SUM(COMPRA.quantidade_itens) AS Total_Itens
FROM PESSOA INNER JOIN COMPRA ON PESSOA.CPF = COMPRA.CPF_consumidor
	GROUP BY PESSOA.nome, PESSOA.CPF
	ORDER BY PESSOA.nome


-->Q3. Total de item vendido, pre�o unitario,
-- quantidade comprada e quantidade dispon�vel,
-- agrupando pelo nome do item e ordenando-o de forma ascendente

SELECT ITEM.Nome AS Item,
	ITEM.pre�o AS Pre�o_Unitario,
	SUM(ITEM_COMPRADO.quantidade_comprada) AS Quantidade_Comprada,
	ITEM.quantidade_estoque AS Quantidade_Disponivel
FROM ITEM LEFT JOIN ITEM_COMPRADO ON ITEM.id = ITEM_COMPRADO.id_item
	RIGHT JOIN COMPRA ON ITEM_COMPRADO.id_compra = COMPRA.id
	GROUP BY ITEM.nome, ITEM.pre�o, ITEM.quantidade_estoque
	ORDER BY ITEM.nome ASC


-->Q4.Obter o endere�o completo do cadastro de Pessoas residentes
-- em um determinado estado, a quantidade de Rotelland_points
-- dessa pessoa e calculando sua idade

DECLARE @estado AS varchar(10) = 'S�o Paulo'

SELECT PESSOA.nome AS Nome, 
	CONCAT(CEP.logradouro, ', ', CEP.bairro, ' - ', CEP.estado, ' - ', CEP.CEP) AS Endereco,
	CARTEIRA.Rotelland_points AS RTL_Points,
	(DATEDIFF(YEAR, PESSOA.data_nascimento, GETDATE())) AS Idade
FROM PESSOA RIGHT JOIN CEP ON PESSOA.CEP = CEP.CEP
	RIGHT JOIN CARTEIRA ON PESSOA.id_carteira = CARTEIRA.id
WHERE CEP.estado = @estado
	ORDER BY NOME

-->Q5.Obter a rela��o de itens de uma determinada categoria, convertendo
-- o tempo de uso de m�s para dias, ordenando com base no nome do item

declare @categ as varchar(20) = 'Cadernos'

SELECT ITEM.nome AS Item, CATEGORIA_ITEM.categoria AS Categoria,
	(CONVERT(TINYINT, ITEM.tempo_uso)*30) AS Tempo_Uso_Dias
FROM ITEM LEFT JOIN CATEGORIA_ITEM ON ITEM.id_categoria = CATEGORIA_ITEM.id
WHERE CATEGORIA_ITEM.categoria = @categ
	ORDER BY ITEM.nome