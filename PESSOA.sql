--Realiza��o do cadastro/altera��o de usu�rio
USE Rotelland
GO

--Para fazer atualiza��es no cadastro da PESSOA, basta colocar o CPF + o campo que deseja atualizar
declare @CPF as char(11) = '59163186004'
declare @nome as varchar(80) = 'F�bio Gon�alves Louren�o'
declare @email as varchar(50) = 'fabiolourenco15@gmail.com'
declare @dnasc as date = '1997-01-15'
declare @CEP as char(8) = '11013161'
declare @num as int = 246
declare @compl as varchar(20) = 'apto 32'	--pode ser nulo
declare @banco as varchar(20)				--pode ser nulo
declare @num_agenc as varchar(10)			--pode ser nulo
declare @num_conta as varchar(15)			--pode ser nulo
declare @entrega_dom as char(1)				--pode ser nulo
declare @celular as char(12) = '13991312498'
declare @senha as varchar(50) = 'fbgcvs15'

--CARTEIRA: N�O preencher essa informa��o, pois ser� gerada automaticamente
declare @id_carteira as varchar(50)

--FORMAS_PAGAMENTO (essa informa��o pode estar nula)
declare @id_metodo_pagamento as char(1)

--CARTAO (essas informa��es podem estar nulas)
declare @num_cartao as char(16)
declare @id_tipo_cartao as char(1)
declare @codigo_seguran�a as char(3)
declare @data_validade as date
declare @nome_card as varchar(30)

BEGIN TRANSACTION
	IF @@TRANCOUNT = 1

		BEGIN
			--Verificar se este CPF est� cadastrado no sistema, se sim, ser� realizado um UPDATE no registro
			IF((SELECT COUNT(*) FROM PESSOA WHERE CPF = @CPF) > 0)
				BEGIN
					IF(@nome IS NOT NULL AND (SELECT nome FROM PESSOA WHERE CPF = @CPF) != @nome)
						BEGIN
							UPDATE PESSOA SET nome = @nome WHERE CPF = @CPF
							PRINT 'O Nome foi atualizado com sucesso!'
						END

					IF(@email IS NOT NULL AND (SELECT email FROM PESSOA WHERE CPF = @CPF) != @email)
						BEGIN
							UPDATE PESSOA SET email = email WHERE CPF = @CPF
							PRINT 'O E-mail foi atualizado com sucesso!'
						END

					IF(@CEP IS NOT NULL AND (SELECT CEP FROM PESSOA WHERE CPF = @CPF) != @CEP)
						BEGIN
							IF((SELECT COUNT(*) FROM CEP WHERE CEP = @CEP) > 0)
								BEGIN
									UPDATE PESSOA SET CEP = @CEP WHERE CPF = @CPF
									PRINT 'O CEP foi atualizado com sucesso!'
								END
							ELSE
								PRINT 'Este CEP n�o est� cadastrado. Por favor, realize o cadastro deste.'
						END

					IF(@num IS NOT NULL AND (SELECT n�mero FROM PESSOA WHERE CPF = @CPF) != @num)
						BEGIN
							UPDATE PESSOA SET n�mero = @num WHERE CPF = @CPF
							PRINT 'O N�mero do endere�o foi atualizado com sucesso!'
						END

					IF(@compl IS NOT NULL AND (SELECT complemento FROM PESSOA WHERE CPF = @CPF) != @compl)
						BEGIN
							UPDATE PESSOA SET complemento = @compl WHERE CPF = @CPF
							PRINT 'O Complemento do endere�o foi atualizado com sucesso!'
						END

					IF(@banco IS NOT NULL AND (SELECT nome_banco FROM PESSOA WHERE CPF = @CPF) != @banco)
						BEGIN
							UPDATE PESSOA SET nome_banco = @banco WHERE CPF = @CPF
							PRINT 'O Nome do Banco foi atualizado com sucesso!'
						END

					IF(@num_agenc IS NOT NULL AND (SELECT n�mero_ag�ncia FROM PESSOA WHERE CPF = @CPF) != @num_agenc)
						BEGIN
							UPDATE PESSOA SET n�mero_ag�ncia = @num_agenc WHERE CPF = @CPF
							PRINT 'O N�mero da Ag�ncia foi atualizado com sucesso!'
						END

					IF(@num_conta IS NOT NULL AND (SELECT n�mero_conta FROM PESSOA WHERE CPF = @CPF) != @num_conta)
						BEGIN
							UPDATE PESSOA SET n�mero_conta = @num_conta WHERE CPF = @CPF
							PRINT 'O N�mero da Conta banc�ria foi atualizado com sucesso!'
						END

					IF(@entrega_dom IS NOT NULL AND (SELECT id_entrega_domicilio FROM PESSOA WHERE CPF = @CPF) != @entrega_dom)
						BEGIN
							UPDATE PESSOA SET id_entrega_domicilio = @entrega_dom WHERE CPF = @CPF
							PRINT 'A informa��o de entrega � domic�lio foi atualizada com sucesso!'
						END

					IF(@celular IS NOT NULL AND (SELECT celular FROM PESSOA WHERE CPF = @CPF) != @celular)
						BEGIN
							UPDATE PESSOA SET celular = @celular WHERE CPF = @CPF
							PRINT 'O Celular foi atualizado com sucesso!'
						END

					IF(@senha IS NOT NULL AND (SELECT senha FROM PESSOA WHERE CPF = @CPF) != @senha)
						BEGIN
							UPDATE PESSOA SET senha = @senha WHERE CPF = @CPF
							PRINT 'A Senha foi atualizada com sucesso!'
						END

					--inserindo forma de pagamento aceita (se houver alguma para ser cadastrada)
					IF((@id_metodo_pagamento IS NOT NULL) AND
						(SELECT COUNT(*) FROM FORMAS_PAGAMENTO WHERE CPF_fornecedor = @CPF
																AND id_metodo_pagamento = @id_metodo_pagamento) = 0)
						BEGIN
							INSERT INTO FORMAS_PAGAMENTO(CPF_fornecedor, id_metodo_pagamento)
							VALUES(@CPF, @id_metodo_pagamento)
						END

					--inserindo dados do cart�o (se houver algum para ser cadastrado)
					IF(@num_cartao IS NOT NULL)
						BEGIN
							INSERT INTO CARTAO(numero_cartao, id_tipo_cartao, codigo_seguran�a, data_validade,
												nome, CPF)
							VALUES(@num_cartao, @id_tipo_cartao, @codigo_seguran�a, @data_validade, @nome_card,
									@CPF)
						END
				END
		--Caso n�o exista o CPF no sistema, um novo registro de PESSOA ser� INSERIDO!
			ELSE
				BEGIN
					--Verificar se o CEP informado existe no BD
					IF((SELECT COUNT(*) FROM CEP WHERE CEP = @CEP) > 0)
						BEGIN
							SET @id_carteira = CONCAT(@CPF, @dnasc)
							INSERT INTO CARTEIRA
							VALUES(@id_carteira, 0)

							INSERT INTO PESSOA (CPF, nome, email, data_nascimento, CEP, n�mero, complemento, nome_banco,
												n�mero_ag�ncia, n�mero_conta, id_entrega_domicilio, id_carteira, celular,
												senha)
							VALUES(@CPF, @nome, @email, @dnasc, @CEP, @num, @compl, @banco, @num_agenc, @num_conta,
									@entrega_dom, @id_carteira, @celular, @senha)

							--inserindo forma de pagamento aceita (se houver alguma para ser cadastrada)
							IF((@id_metodo_pagamento IS NOT NULL) AND
								(SELECT COUNT(*) FROM FORMAS_PAGAMENTO WHERE CPF_fornecedor = @CPF
																			AND id_metodo_pagamento = @id_metodo_pagamento) = 0)
								BEGIN
									INSERT INTO FORMAS_PAGAMENTO(CPF_fornecedor, id_metodo_pagamento)
									VALUES(@CPF, @id_metodo_pagamento)
								END

							--inserindo dados do cart�o (se houver algum para ser cadastrado)
							IF(@num_cartao IS NOT NULL)
								BEGIN
									INSERT INTO CARTAO(numero_cartao, id_tipo_cartao, codigo_seguran�a, data_validade,
														nome, CPF)
									VALUES(@num_cartao, @id_tipo_cartao, @codigo_seguran�a, @data_validade, @nome_card,
											@CPF)
								END
						END
					--Caso o CEP n�o exista no BD, informar p/ cadastrar
					ELSE
						BEGIN
							PRINT 'Este CEP n�o est� cadastrado. Por favor, realize o cadastro deste.'
						END
				END
		COMMIT
		END

	ELSE
		ROLLBACK TRANSACTION