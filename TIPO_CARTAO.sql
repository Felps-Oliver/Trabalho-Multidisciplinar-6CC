--Inser��o dos valores padr�es das op��es de TIPO_CARTAO

USE Rotelland
GO

declare @id as char(1) = '1'
declare @desc as varchar(7) = 'CR�DITO'

BEGIN TRANSACTION
	IF @@TRANCOUNT = 1

		BEGIN
			IF((@id = '0' AND @desc = 'D�BITO') OR (@id = '1' AND @desc = 'CR�DITO'))
				INSERT INTO TIPO_CARTAO(id, tipo_cart�o)
				VALUES(@id, @desc)
			ELSE
				PRINT 'Este n�o � um valor permitido para ser inserido.'
		COMMIT
		END

	ELSE
		ROLLBACK TRANSACTION