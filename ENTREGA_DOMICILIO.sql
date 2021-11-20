--Inserção dos valores padrões das opções de ENTREGA_DOMICILIO

USE Rotelland
GO

declare @id as char(1) = '1'
declare @desc as char(3) = 'SIM'

BEGIN TRANSACTION
	IF @@TRANCOUNT = 1

		BEGIN
			IF((@id = '0' AND @desc = 'NÃO') OR (@id = '1' AND @desc = 'SIM'))
				INSERT INTO ENTREGA_DOMICILIO(id, entrega_domicilio)
				VALUES(@id, @desc)
			ELSE
				PRINT 'Este não é um valor permitido para ser cadastrado.'
		COMMIT
		END

	ELSE
		ROLLBACK TRANSACTION