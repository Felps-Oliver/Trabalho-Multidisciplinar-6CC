--Inserção de CUPOM
USE Rotelland
GO

declare @id as varchar(50)
declare @nome as varchar(50) = 'FIM DE ANO ROTELLAND'
declare @valor_desconto as float = 12.00
declare @validade_inicio as date = '2021-11-20'
declare @validade_fim as date = '2021-12-31'
declare @percentual as int		--pode ser nulo

--NÃO preencher esse campo, pois será setado corretamente de acordo com as datas de validade
declare @isValid as char(1)

BEGIN TRANSACTION
	IF @@TRANCOUNT = 1

		BEGIN
			SET @id = CONCAT(@valor_desconto, @percentual, @validade_inicio, @validade_fim)

			--Verificando se o cupom está válido
			IF(GETDATE() >= @validade_inicio AND GETDATE() <= @validade_fim)
				SET @isValid = '1'
			ELSE
				SET @isValid = '0'

			INSERT INTO CUPOM(id, nome, valor_desconto, validade_inicio, validade_fim, está_válido,
							  percentual_valor)
			VALUES(@id, @nome, @valor_desconto, @validade_inicio, @validade_fim, @isValid, @percentual)
		COMMIT
		END

	ELSE
		ROLLBACK TRANSACTION