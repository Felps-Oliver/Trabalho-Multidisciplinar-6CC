--Inserção de CATEGORIA_ITEM
USE Rotelland
GO

declare @id as varchar(15) = '13'
declare @desc as varchar(20) = 'Tintas'

BEGIN TRANSACTION
	IF @@TRANCOUNT = 1

		BEGIN
			IF((SELECT COUNT(*) FROM CATEGORIA_ITEM WHERE id = @id AND categoria = @desc) = 0)
				INSERT INTO CATEGORIA_ITEM(id, categoria)
				VALUES(@id, @desc)
		COMMIT
		END

	ELSE
		ROLLBACK TRANSACTION