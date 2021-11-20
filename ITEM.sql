--Inserção/Atualização de ITEM. A verificação de criação/atualização será feita pelo nome OU id do item
--SE PREENCHER O NOME DO ITEM, PRECISA PREENCHER O CPF TB!
USE Rotelland
GO

declare @id as varchar(50)
declare @nome as varchar(50) = 'Tinta guache 6 cores ACRILEX'
declare @descricao as varchar(900) = 'Marca: Acrilex. As tintas guaches não estão ressecadas. A maioria não foi aberta dos conjuntos.'
declare @CPF_fornecedor as char(11) = '84698955084'
declare @tempo_uso as char(2) = '6'
declare @quantidade_estoque as int = 6
declare @id_categoria as varchar(15) = '13'
declare @preço as float = 3.30
declare @n as int = 0

--Colocar '1' em @deseja_img, caso vc deseja inserir uma imagem.
--Além disso, é necessário alterar o caminho da imagem no SELECT (no update ou insert)
declare @deseja_img as char(1) = '1'

BEGIN TRANSACTION
	IF @@TRANCOUNT = 1

		BEGIN
			--Verificando se já existe um item com esse nome para esse vendedor, senão, criar
			IF((SELECT COUNT(*) FROM ITEM WHERE nome = @nome AND CPF_fornecedor = @CPF_fornecedor) = 0 AND @id IS NULL)
				BEGIN
					--Verificando se este fornecedor possui suas informações bancárias preenchidas
					IF((SELECT nome_banco FROM PESSOA WHERE CPF = @CPF_fornecedor) IS NOT NULL)
						BEGIN
							--Verificando se este fornecedor possui formas de pagamento aceitas cadastradas
							IF((SELECT COUNT(*) FROM FORMAS_PAGAMENTO WHERE CPF_fornecedor = @CPF_fornecedor) > 0)
								BEGIN
									--Verificando se está sendo passada uma quantidade de itens no estoque > 0
									IF(@quantidade_estoque > 0)
										BEGIN
											--Verificando se o preço do item a ser inserido é > 0
											IF(@preço > 0)
												BEGIN
													--Verificando se esta categoria existe no BD
													IF((SELECT COUNT(*) FROM CATEGORIA_ITEM WHERE id = @id_categoria) > 0)
														BEGIN
															--Verificando se este fornecedor preencheu se faz entregas a domicílio ou não
															IF((SELECT id_entrega_domicilio FROM PESSOA WHERE CPF = @CPF_fornecedor) IS NOT NULL)
																BEGIN
																	SET @n = (SELECT COUNT(*) FROM ITEM WHERE CPF_fornecedor = @CPF_fornecedor)
																	SET @id = CONCAT(@n, '-', @CPF_fornecedor)

																	INSERT INTO ITEM(id, nome, descricao, CPF_fornecedor, tempo_uso, quantidade_estoque,
																					 id_categoria, preço)
																	VALUES(@id, @nome, @descricao, @CPF_fornecedor, @tempo_uso, @quantidade_estoque,
																		   @id_categoria, @preço)

																	--Verificando se há caminho de imagem, caso contrário, não inserir
																	IF(@deseja_img = '1')
																		BEGIN
																			UPDATE ITEM
																			SET imagem_item = (SELECT * FROM OPENROWSET(BULK 'C:\Users\Gabrielle\Desktop\produtos\tinta guache 6 cores.jpg', SINGLE_BLOB) AS imagem_item)
																			WHERE id = @id
																		END
																END
															ELSE
																PRINT 'Você precisa preencher se realiza entregas a domicílio ou não.'
														END
													ELSE
														PRINT 'Esta categoria de item não está cadastrada.'
												END
											ELSE
												PRINT 'Você só pode cadastrar itens cujo preço seja maior do que zero'
										END
									ELSE
										PRINT 'Você não pode cadastrar um item com quantidade de estoque menor que 1 (um).'
								END
							ELSE
								PRINT 'Você precisa cadastrar uma forma de pagamento aceita antes de cadastrar um item.'
						END
					ELSE
						PRINT 'Você precisa cadastrar suas informações bancárias corretamente antes de cadastrar um item.'
				END
			--Caso já exista um item com esse nome, atualizar as informações
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
							PRINT 'A Descrição do Item foi atualizada com sucesso!'
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
								PRINT 'A Quantidade de Estoque do Item não pôde ser atualizada, pois não pode ser menor que 1 (um).'
						END

					IF(@id_categoria IS NOT NULL AND (SELECT id_categoria FROM ITEM WHERE (id = @id OR nome = @nome)) != @id_categoria)
						BEGIN
							UPDATE ITEM SET id_categoria = @id_categoria WHERE (id = @id OR nome = @nome)
							PRINT 'A Categoria do Item foi atualizada com sucesso!'
						END

					IF(@preço IS NOT NULL AND (SELECT preço FROM ITEM WHERE (id = @id OR nome = @nome)) != @preço)
						BEGIN
							IF(@preço > 0)
								BEGIN
									UPDATE ITEM SET preço = @preço WHERE (id = @id OR nome = @nome)
									PRINT 'O Preço do Item foi atualizado com sucesso!'
								END
							ELSE
								PRINT 'O Preço do Item não pôde ser atualizado, pois não pode ser igual a zero.'
						END

					--Verificando se há caminho de imagem, caso contrário, não att
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