DECLARE @Query NVARCHAR(4000) = 'SELECT TOP (1000) [ParentProductCategoryName]
      ,[ProductCategoryName]
      ,[ProductCategoryID]
  FROM [AdventureWorksLT].[SalesLT].[vGetAllCategories]';

EXEC performance.pInsertQuery @Query = @Query;

SELECT @Query = 'DECLARE @Status tinyint = 2
SELECT [dbo].[ufnGetSalesOrderStatusText](@Status)'
EXEC performance.pInsertQuery @Query = @Query;

--sp_helpText 'performance.pInsertQuery'
SELECT * FROM performance.Queries