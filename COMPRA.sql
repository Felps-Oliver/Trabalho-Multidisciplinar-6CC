--Transa��o para inserir a compra, gerar o recibo e inserir os itens na compra
USE Rotelland
GO

--COMPRA
declare @id as varchar(50)
declare @CPF_fornecedor as char(11) = '58671505006'
declare @CPF_consumidor as char(11) = '47212805050'
declare @id_metodo_pagamento as char(1) = '1'
declare @valor_frete as float = 30
declare @nome_cupom as varchar(50) = 'BLACKFRIDAY2021' --pode ser nulo


--Insira o n�mero do recibo caso vc apenas queira adicionar + itens na sua compra
declare @id_recibo as char(9) = '1'


--Inser��o dos itens desta compra (ITEM_COMPRADO), repita essa estrutura quantas vezes quiser
declare @id_compra as varchar(50)
declare @id_item as varchar(50) = '1-58671505006'
declare @quantidade_comprada as int = 1


--Estes n�o devem ser mexidos, pois ser�o atualizados conforme os itens s�o inseridos na compra
declare @valor_total_itens as float = 0
declare @desconto as float = 0
declare @valor_total_compra as float = 0


--Estes n�o devem ser preenchidos, pois ser�o puxados do consumidor
declare @CEP_entrega as char(8)
declare @numero_entrega as int
declare @complemento_entrega as varchar(20)


--Vari�veis auxiliares
declare @value as float = 0
declare @percent as float = 0
declare @id_cupom as varchar(50)
declare @numero_cartao as char(16)
declare @item_pre�o as float
declare @RTL_points as int
declare @id_carteira as varchar(50)
declare @Rotelland_points as int

BEGIN TRANSACTION
	IF @@TRANCOUNT = 1

		BEGIN
			--Verificando se o item que est� sendo inserido na compra pertence ao fornecedor dela
			IF((SELECT CPF_fornecedor FROM ITEM WHERE id = @id_item) = @CPF_fornecedor)
				BEGIN
					--Verificando se h� estoque suficiente para comprar a quantidade desejada
					IF((SELECT quantidade_estoque FROM ITEM WHERE id = @id_item) >= @quantidade_comprada)
						BEGIN
							--Se o valor do recibo estiver igual a nulo, significa que � uma nova inst�ncia
							IF(@id_recibo IS NULL)
								BEGIN
									--Certificando-se caso o consumidor tenha escolhido cart�o como m�todo pgto, tenha um cart�o cadastrado
									IF((@id_metodo_pagamento = '2') OR
										(@id_metodo_pagamento = '0' AND (SELECT id_tipo_cartao FROM CARTAO WHERE CPF = @CPF_consumidor
																										  AND id_tipo_cartao = '0') > 0) OR
										(@id_metodo_pagamento = '1' AND (SELECT id_tipo_cartao FROM CARTAO WHERE CPF = @CPF_consumidor
																										  AND id_tipo_cartao = '1') > 0))
										BEGIN
											SET @id_recibo = (SELECT COUNT(*) FROM RECIBO)
											SET @id = CONCAT('RTL-', @CPF_fornecedor, @CPF_consumidor, @id_recibo)

											--Inserindo o recibo
											INSERT INTO RECIBO(id, valor_total, data_emiss�o)
											VALUES(@id_recibo, 0, GETDATE())

											--Pegando as informa��es de endere�o de entrega do consumidor
											SET @CEP_entrega = (SELECT CEP FROM PESSOA WHERE CPF = @CPF_consumidor)
											SET @numero_entrega = (SELECT n�mero FROM PESSOA WHERE CPF = @CPF_consumidor)
											SET @complemento_entrega = (SELECT complemento FROM PESSOA WHERE CPF = @CPF_consumidor)

											--Encontrando o id do cupom
											SET @id_cupom = (SELECT id FROM CUPOM WHERE est�_v�lido = '1' AND nome = @nome_cupom)

											--Pegando o n�mero do cart�o conforme m�todo do pagamento escolhido
											IF(@id_metodo_pagamento = '0')
													SET @numero_cartao = (SELECT numero_cartao FROM CARTAO WHERE id_tipo_cartao = '0'
																										   AND CPF = @CPF_consumidor)
											ELSE
												BEGIN
													IF(@id_metodo_pagamento = '1')
														SET @numero_cartao = (SELECT numero_cartao FROM CARTAO WHERE id_tipo_cartao = '1'
																										   AND CPF = @CPF_consumidor)
												END

											--Instanciando a compra
											INSERT INTO COMPRA(id, CPF_fornecedor, CPF_consumidor, CEP_entrega, numero_entrega,
															  complemento_entrega, data_compra, quantidade_itens, id_metodo_pagamento,
															  valor_total_itens, valor_frete, id_cupom, desconto, valor_total_compra,
															  id_recibo, numero_cartao)
											VALUES(@id, @CPF_fornecedor, @CPF_consumidor, @CEP_entrega, @numero_entrega, @complemento_entrega,
													GETDATE(), 0, @id_metodo_pagamento, 0, @valor_frete, @id_cupom, 0, @valor_frete, @id_recibo,
													@numero_cartao)

											--Inserindo os itens nessa compra
											IF((SELECT COUNT(*) FROM COMPRA WHERE id = @id) > 0)
												BEGIN
													IF((SELECT COUNT(*) FROM ITEM_COMPRADO WHERE id_compra = @id AND id_recibo = @id_recibo AND
																						   id_item = @id_item) > 0)
														UPDATE ITEM_COMPRADO
														SET quantidade_comprada = quantidade_comprada + quantidade_comprada
														WHERE id_compra = @id AND id_recibo = @id_recibo AND id_item = @id_item
													ELSE
														INSERT INTO ITEM_COMPRADO(id_compra, id_recibo, id_item, quantidade_comprada)
														VALUES(@id, @id_recibo, @id_item, @quantidade_comprada)
					
													SET @value = (SELECT pre�o FROM ITEM WHERE id = @id_item) * @quantidade_comprada

													--Atualizando o estoque do item
													UPDATE ITEM
													SET quantidade_estoque = (quantidade_estoque - @quantidade_comprada)
													WHERE id = @id_item

													--Atualizando a compra
													UPDATE COMPRA
													SET quantidade_itens = (quantidade_itens + @quantidade_comprada),
														valor_total_itens = (valor_total_itens + @value),
														valor_total_compra = ((valor_total_compra + @value) - @desconto)
													WHERE id = @id

													SET @valor_total_itens = (SELECT valor_total_itens FROM COMPRA WHERE id = @id)

													SET @item_pre�o = (SELECT pre�o FROM ITEM WHERE id = @id_item)
													--Atualizando o desconto, caso haja um cupom
													IF(@id_cupom IS NOT NULL)
														BEGIN
															SET @percent = (SELECT percentual_valor FROM CUPOM WHERE id = @id_cupom)
															IF(@percent IS NOT NULL)
																BEGIN
																	SET @desconto = ((@item_pre�o * @quantidade_comprada) * (@percent/100))

																	--Atualizando o desconto na compra
																	UPDATE COMPRA
																	SET desconto = desconto + @desconto,
																		valor_total_itens = (valor_total_itens - @desconto),
																		valor_total_compra = (valor_total_compra - @desconto)
																	WHERE id = @id
																END
															ELSE
																BEGIN
																	SET @desconto = (SELECT valor_desconto FROM CUPOM WHERE id = @id_cupom)
																	--Atualizando o desconto na compra
																	IF(((SELECT desconto FROM COMPRA WHERE id = @id) = 0) AND
																	   ((SELECT valor_total_compra FROM COMPRA WHERE id = @id) > @desconto))
																		UPDATE COMPRA
																		SET desconto = @desconto,
																			valor_total_itens = (valor_total_itens - @desconto),
																			valor_total_compra = (valor_total_compra - @desconto)
																		WHERE id = @id
																END
														END
					

													--Atualizando o valor do recibo
													SET @valor_total_compra = (SELECT valor_total_compra FROM COMPRA WHERE id = @id)

													UPDATE RECIBO
													SET valor_total = (@valor_total_compra - @valor_frete)
													WHERE id = @id_recibo

													--Atualizando os Rotelland Points do consumidos
													SET @RTL_points = ((@item_pre�o * @quantidade_comprada) * 0.10)

													SET @id_carteira = (SELECT id_carteira FROM PESSOA WHERE CPF = @CPF_consumidor)

													SET @Rotelland_points = (SELECT Rotelland_points FROM CARTEIRA WHERE id = @id_carteira)

													UPDATE CARTEIRA
													SET Rotelland_points = (@Rotelland_points + @RTL_points)
													WHERE id = @id_carteira
												END
										END
									ELSE
										PRINT 'Para usar este m�todo de pagamento, cadastre um cart�o.'
								END
							--Caso tenhamos o valor do recibo, significa que iremos inserir itens na compra e mudar o  recibo
							ELSE
								BEGIN
									SET @id = CONCAT('RTL-', @CPF_fornecedor, @CPF_consumidor, @id_recibo)

									--Encontrando o id do cupom
									SET @id_cupom = (SELECT id FROM CUPOM WHERE est�_v�lido = '1' AND nome = @nome_cupom)

									--Inserindo os itens nessa compra
									IF((SELECT COUNT(*) FROM COMPRA WHERE id = @id) > 0)
										BEGIN
											IF((SELECT COUNT(*) FROM ITEM_COMPRADO WHERE id_compra = @id AND id_recibo = @id_recibo AND
																				   id_item = @id_item) > 0)
												UPDATE ITEM_COMPRADO
												SET quantidade_comprada = quantidade_comprada + quantidade_comprada
												WHERE id_compra = @id AND id_recibo = @id_recibo AND id_item = @id_item
											ELSE
												INSERT INTO ITEM_COMPRADO(id_compra, id_recibo, id_item, quantidade_comprada)
												VALUES(@id, @id_recibo, @id_item, @quantidade_comprada)
					
											SET @value = (SELECT pre�o FROM ITEM WHERE id = @id_item) * @quantidade_comprada

											--Atualizando o estoque do item
											UPDATE ITEM
											SET quantidade_estoque = (quantidade_estoque - @quantidade_comprada)
											WHERE id = @id_item

											--Atualizando a compra
											UPDATE COMPRA
											SET quantidade_itens = (quantidade_itens + @quantidade_comprada),
												valor_total_itens = (valor_total_itens + @value),
												valor_total_compra = ((valor_total_compra + @value) - @desconto)
											WHERE id = @id

											SET @valor_total_itens = (SELECT valor_total_itens FROM COMPRA WHERE id = @id)

											SET @item_pre�o = (SELECT pre�o FROM ITEM WHERE id = @id_item)
											--Atualizando o desconto, caso haja um cupom
											IF(@id_cupom IS NOT NULL)
												BEGIN
													SET @percent = (SELECT percentual_valor FROM CUPOM WHERE id = @id_cupom)
													IF(@percent IS NOT NULL)
														BEGIN
															SET @desconto = ((@item_pre�o * @quantidade_comprada) * (@percent/100))

															--Atualizando o desconto na compra
															UPDATE COMPRA
															SET desconto = desconto + @desconto,
																valor_total_itens = (valor_total_itens - @desconto),
																valor_total_compra = (valor_total_compra - @desconto)
															WHERE id = @id
														END
													ELSE
														BEGIN
															SET @desconto = (SELECT valor_desconto FROM CUPOM WHERE id = @id_cupom)
															--Atualizando o desconto na compra
															IF(((SELECT desconto FROM COMPRA WHERE id = @id) = 0) AND
																((SELECT valor_total_compra FROM COMPRA WHERE id = @id) > @desconto))
																UPDATE COMPRA
																SET desconto = @desconto,
																	valor_total_itens = (valor_total_itens - @desconto),
																	valor_total_compra = (valor_total_compra - @desconto)
																WHERE id = @id
														END
												END
					

											--Atualizando o valor do recibo
											SET @valor_total_compra = (SELECT valor_total_compra FROM COMPRA WHERE id = @id)

											UPDATE RECIBO
											SET valor_total = (@valor_total_compra - @valor_frete)
											WHERE id = @id_recibo

											--Atualizando os Rotelland Points do consumidos
											SET @RTL_points = ((@item_pre�o * @quantidade_comprada) * 0.10)

											SET @id_carteira = (SELECT id_carteira FROM PESSOA WHERE CPF = @CPF_consumidor)

											SET @Rotelland_points = (SELECT Rotelland_points FROM CARTEIRA WHERE id = @id_carteira)

											UPDATE CARTEIRA
											SET Rotelland_points = (@Rotelland_points + @RTL_points)
											WHERE id = @id_carteira
										END
								END
						END
					ELSE
						PRINT 'N�o h� estoque suficiente conforme solicitado para este item.'
				END
			ELSE
				PRINT 'Este item n�o pertence ao fornecedor desta compra!!'
		COMMIT
		END

	ELSE
		ROLLBACK TRANSACTION