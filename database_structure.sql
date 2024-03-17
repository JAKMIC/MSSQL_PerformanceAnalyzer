IF OBJECT_ID('performance.pTextQuery') IS NOT NULL
	DROP PROCEDURE performance.pTextQuery
GO
IF OBJECT_ID('performance.pInsertQuery') IS NOT NULL
	DROP PROCEDURE performance.pInsertQuery
GO
IF OBJECT_ID('performance.Queries') IS NOT NULL
	DROP TABLE performance.Queries
GO
IF SCHEMA_ID('performance') IS NOT NULL
	DROP SCHEMA performance
GO
CREATE SCHEMA performance
GO
CREATE TABLE performance.Queries
(
	ID INT IDENTITY,
	Query NVARCHAR(4000),
	Active BIT DEFAULT (1),
	PRIMARY KEY (ID)
)
GO
CREATE PROCEDURE performance.pInsertQuery (@Query NVARCHAR(4000))
AS
BEGIN
	DECLARE @Return SMALLINT = 1

	IF @Query IS NULL OR LEN(@Query) = 0
	BEGIN 
		SET @Return = -1
		SELECT 'Inserted query is empty or NULL'
	END

	IF EXISTS(SELECT 1 FROM performance.Queries WITH (NOLOCK) WHERE Query = @Query AND Active = 1)
	BEGIN 
		SET @Return = -1
		SELECT 'Query exists in table'
	END

	IF @Return = 1
	BEGIN
		INSERT INTO performance.Queries (Query, Active)
		VALUES	(@Query, 1)

		SELECT 'Query inserted to table'
	END

	RETURN @Return
END
GO
CREATE OR ALTER PROCEDURE performance.pTextQuery (@NumberOfRuns INT, @NumberOfWarmUps INT)
AS
BEGIN
	DECLARE @Query NVARCHAR(4000), @ID INT, @Params NVARCHAR(100)

	IF EXISTS(SELECT 1 FROM performance.Queries WITH (NOLOCK))
	BEGIN
		--SET FMTONLY ON
		DECLARE CUR CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
		SELECT
			ID, Query
		FROM performance.Queries
		ORDER BY ID
		OPEN CUR 
		FETCH NEXT FROM CUR INTO @ID, @Query
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @Params = N'@ID' + CAST(@ID AS nvarchar(100)) + ' INT = NULL'
			EXEC sp_executesql @Query, @Params--3

			FETCH NEXT FROM CUR INTO @ID, @Query
		END
		CLOSE CUR
		DEALLOCATE CUR
	END
END
GO

--EXEC performance.pTextQuery 0,0
--SET FMTONLY ON
--SELECT * FROM sys.tables

--set noexec oFF

--SELECT * FROM sys.tables