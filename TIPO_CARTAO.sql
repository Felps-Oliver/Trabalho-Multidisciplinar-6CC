--Inserção dos valores padrões das opções de TIPO_CARTAO

USE Rotelland
GO

declare @id as char(1) = '1'
declare @desc as varchar(7) = 'CRÉDITO'

BEGIN TRANSACTION
	IF @@TRANCOUNT = 1

		BEGIN
			IF((@id = '0' AND @desc = 'DÉBITO') OR (@id = '1' AND @desc = 'CRÉDITO'))
				INSERT INTO TIPO_CARTAO(id, tipo_cartão)
				VALUES(@id, @desc)
			ELSE
				PRINT 'Este não é um valor permitido para ser inserido.'
		COMMIT
		END

	ELSE
		ROLLBACK TRANSACTION