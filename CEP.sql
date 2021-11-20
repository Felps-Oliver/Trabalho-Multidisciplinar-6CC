--Inserção de CEPs
USE Rotelland
GO

declare @CEP as char(8) = '93270450'
declare @cidade as varchar(30) = 'Esteio'
declare @estado as varchar(30) = 'Rio Grande do Sul'
declare @bairro as varchar(30) = 'Novo Esteio'
declare @logradouro as varchar(30) = 'Rua Luiz Ernesto Capra'

BEGIN TRANSACTION
	IF @@TRANCOUNT = 1

		BEGIN
			INSERT INTO CEP(CEP, cidade, estado, bairro, logradouro)
			VALUES(@CEP, @cidade, @estado, @bairro, @logradouro)
		COMMIT
		END

	ELSE
		ROLLBACK TRANSACTION