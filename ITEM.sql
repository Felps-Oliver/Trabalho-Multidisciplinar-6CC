--Inser��o/Atualiza��o de ITEM. A verifica��o de cria��o/atualiza��o ser� feita pelo nome OU id do item
--SE PREENCHER O NOME DO ITEM, PRECISA PREENCHER O CPF TB!
USE Rotelland
GO

declare @id as varchar(50)
declare @nome as varchar(50) = 'Tinta guache 6 cores ACRILEX'
declare @descricao as varchar(900) = 'Marca: Acrilex. As tintas guaches n�o est�o ressecadas. A maioria n�o foi aberta dos conjuntos.'
declare @CPF_fornecedor as char(11) = '84698955084'
declare @tempo_uso as char(2) = '6'
declare @quantidade_estoque as int = 6
declare @id_categoria as varchar(15) = '13'
declare @pre�o as float = 3.30
declare @n as int = 0

--Colocar '1' em @deseja_img, caso vc deseja inserir uma imagem.
--Al�m disso, � necess�rio alterar o caminho da imagem no SELECT (no update ou insert)
declare @deseja_img as char(1) = '1'

BEGIN TRANSACTION
	IF @@TRANCOUNT = 1

		BEGIN
			--Verificando se j� existe um item com esse nome para esse vendedor, sen�o, criar
			IF((SELECT COUNT(*) FROM ITEM WHERE nome = @nome AND CPF_fornecedor = @CPF_fornecedor) = 0 AND @id IS NULL)
				BEGIN
					--Verificando se este fornecedor possui suas informa��es banc�rias preenchidas
					IF((SELECT nome_banco FROM PESSOA WHERE CPF = @CPF_fornecedor) IS NOT NULL)
						BEGIN
							--Verificando se este fornecedor possui formas de pagamento aceitas cadastradas
							IF((SELECT COUNT(*) FROM FORMAS_PAGAMENTO WHERE CPF_fornecedor = @CPF_fornecedor) > 0)
								BEGIN
									--Verificando se est� sendo passada uma quantidade de itens no estoque > 0
									IF(@quantidade_estoque > 0)
										BEGIN
											--Verificando se o pre�o do item a ser inserido � > 0
											IF(@pre�o > 0)
												BEGIN
													--Verificando se esta categoria existe no BD
													IF((SELECT COUNT(*) FROM CATEGORIA_ITEM WHERE id = @id_categoria) > 0)
														BEGIN
															--Verificando se este fornecedor preencheu se faz entregas a domic�lio ou n�o
															IF((SELECT id_entrega_domicilio FROM PESSOA WHERE CPF = @CPF_fornecedor) IS NOT NULL)
																BEGIN
																	SET @n = (SELECT COUNT(*) FROM ITEM WHERE CPF_fornecedor = @CPF_fornecedor)
																	SET @id = CONCAT(@n, '-', @CPF_fornecedor)

																	INSERT INTO ITEM(id, nome, descricao, CPF_fornecedor, tempo_uso, quantidade_estoque,
																					 id_categoria, pre�o)
																	VALUES(@id, @nome, @descricao, @CPF_fornecedor, @tempo_uso, @quantidade_estoque,
																		   @id_categoria, @pre�o)

																	--Verificando se h� caminho de imagem, caso contr�rio, n�o inserir
																	IF(@deseja_img = '1')
																		BEGIN
																			UPDATE ITEM
																			SET imagem_item = (SELECT * FROM OPENROWSET(BULK 'C:\Users\Gabrielle\Desktop\produtos\tinta guache 6 cores.jpg', SINGLE_BLOB) AS imagem_item)
																			WHERE id = @id
																		END
																END
															ELSE
																PRINT 'Voc� precisa preencher se realiza entregas a domic�lio ou n�o.'
														END
													ELSE
														PRINT 'Esta categoria de item n�o est� cadastrada.'
												END
											ELSE
												PRINT 'Voc� s� pode cadastrar itens cujo pre�o seja maior do que zero'
										END
									ELSE
										PRINT 'Voc� n�o pode cadastrar um item com quantidade de estoque menor que 1 (um).'
								END
							ELSE
								PRINT 'Voc� precisa cadastrar uma forma de pagamento aceita antes de cadastrar um item.'
						END
					ELSE
						PRINT 'Voc� precisa cadastrar suas informa��es banc�rias corretamente antes de cadastrar um item.'
				END
			--Caso j� exista um item com esse nome, atualizar as informa��es
			ELSE
				BEGIN
					IF(@nome IS NOT NULL AND (SELECT nome FROM ITEM WHERE (id = @id OR nome = @nome)) != @nome)
						BEGIN
							UPDATE ITEM SET nome = @nome WHERE (id = @id OR nome = @nome)
							PRINT 'O Nome do Item foi atualizado com sucesso!'
						END

					IF(@descricao IS NOT NULL AND (SELECT descricao FROM ITEM WHERE (id = @id OR nome = @nome)) != @descricao)
						BEGIN
							UPDATE ITEM SET descricao = @descricao WHERE (id = @id OR nome = @nome)
							PRINT 'A Descri��o do Item foi atualizada com sucesso!'
						END

					IF(@tempo_uso IS NOT NULL AND (SELECT tempo_uso FROM ITEM WHERE (id = @id OR nome = @nome)) != @tempo_uso)
						BEGIN
							UPDATE ITEM SET tempo_uso = @tempo_uso WHERE (id = @id OR nome = @nome)
							PRINT 'O Tempo de Uso do Item foi atualizado com sucesso!'
						END

					IF(@quantidade_estoque IS NOT NULL AND (SELECT quantidade_estoque
															FROM ITEM WHERE (id = @id OR nome = @nome)) != @quantidade_estoque)
						BEGIN
							IF(@quantidade_estoque > 0)
								BEGIN
									UPDATE ITEM SET quantidade_estoque = @quantidade_estoque WHERE (id = @id OR nome = @nome)
									PRINT 'A Quantidade de Estoque do Item foi atualizada com sucesso!'
								END
							ELSE
								PRINT 'A Quantidade de Estoque do Item n�o p�de ser atualizada, pois n�o pode ser menor que 1 (um).'
						END

					IF(@id_categoria IS NOT NULL AND (SELECT id_categoria FROM ITEM WHERE (id = @id OR nome = @nome)) != @id_categoria)
						BEGIN
							UPDATE ITEM SET id_categoria = @id_categoria WHERE (id = @id OR nome = @nome)
							PRINT 'A Categoria do Item foi atualizada com sucesso!'
						END

					IF(@pre�o IS NOT NULL AND (SELECT pre�o FROM ITEM WHERE (id = @id OR nome = @nome)) != @pre�o)
						BEGIN
							IF(@pre�o > 0)
								BEGIN
									UPDATE ITEM SET pre�o = @pre�o WHERE (id = @id OR nome = @nome)
									PRINT 'O Pre�o do Item foi atualizado com sucesso!'
								END
							ELSE
								PRINT 'O Pre�o do Item n�o p�de ser atualizado, pois n�o pode ser igual a zero.'
						END

					--Verificando se h� caminho de imagem, caso contr�rio, n�o att
					IF(@deseja_img = '1')
						BEGIN
							UPDATE ITEM
							SET imagem_item = (SELECT * FROM OPENROWSET(BULK 'C:\Users\Gabrielle\Desktop\produtos\livro o mundo de sofia.jpg', SINGLE_BLOB) AS imagem_item)
							WHERE (id = @id OR nome = @nome)
						END
				END
		COMMIT
		END

	ELSE
		ROLLBACK TRANSACTION