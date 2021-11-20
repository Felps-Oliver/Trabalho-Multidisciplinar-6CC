--Inser��o dos valores padr�es das op��es de METODO_PAGAMENTO
USE Rotelland
GO

declare @id as char(1) = '2'
declare @desc as varchar(10) = 'BOLETO'

BEGIN TRANSACTION
	IF @@TRANCOUNT = 1

		BEGIN
			IF((@id = '0' AND @desc = 'D�BITO') OR (@id = '1' AND @desc = 'CR�DITO') OR
			   (@id = '2' AND @desc = 'BOLETO'))
				INSERT INTO METODO_PAGAMENTO(id, metodo_pagamento)
				VALUES(@id, @desc)
			ELSE
				PRINT 'Este n�o � um valor permitido para ser inserido.'
		COMMIT
		END

	ELSE
		ROLLBACK TRANSACTION