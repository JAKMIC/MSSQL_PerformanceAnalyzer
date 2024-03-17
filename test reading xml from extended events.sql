--/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT TOP (1000) [ParentProductCategoryName]
--      ,[ProductCategoryName]
--      ,[ProductCategoryID]
--  FROM [AdventureWorksLT].[SalesLT].[vGetAllCategories]

--SELECT *
--FROM sys.fn_xe_file_target_read_file('C:\MSSQL_PerformanceAnalyzer\MSSQL_PerformanceAnalyzer\*.xel', NULL, NULL, NULL);





DECLARE @XML XML = 
	'<event name="sql_statement_completed" package="sqlserver" timestamp="2024-03-15T17:49:59.667Z"><data name="duration"><value>1079</value></data><data name="cpu_time"><value>0</value></data><data name="page_server_reads"><value>0</value></data><data name="physical_reads"><value>0</value></data><data name="logical_reads"><value>513</value></data><data name="writes"><value>0</value></data><data name="spills"><value>0</value></data><data name="row_count"><value>37</value></data><data name="last_row_count"><value>37</value></data><data name="line_number"><value>2</value></data><data name="offset"><value>124</value></data><data name="offset_end"><value>442</value></data><data name="statement"><value><![CDATA[SELECT TOP (1000) [ParentProductCategoryName]
      ,[ProductCategoryName]
      ,[ProductCategoryID]
  FROM [AdventureWorksLT].[SalesLT].[vGetAllCategories]]]></value></data><data name="parameterized_plan_handle"><value></value></data><action name="database_name" package="sqlserver"><value><![CDATA[AdventureWorksLT]]></value></action></event>'


SELECT
	*
FROM (
	SELECT 
		T.c.value('@name', 'varchar(100)') AS [value],
		T.c.value('.', 'varchar(max)') AS [result]
	FROM @XML.nodes('/event/data') T(c)
	WHERE T.c.value('@name', 'varchar(100)') IN ('duration', 'logical_reads', 'writes','statement')
	) t
PIVOT (MAX([Result]) FOR [Value] IN ([duration], [logical_reads], [writes], [statement])) p



SELECT *
FROM sys.fn_xe_file_target_read_file('C:\MSSQL_PerformanceAnalyzer\*.xel', NULL, NULL, NULL) x
OUTER APPLY (SELECT CAST(x.event_data AS xml) xmlToAnalyze) x1
OUTER APPLY (SELECT
				*
			FROM (
				SELECT 
					T.c.value('@name', 'varchar(100)') AS [value],
					T.c.value('.', 'varchar(max)') AS [result]
				FROM x1.xmlToAnalyze.nodes('/event/data') T(c)
				WHERE T.c.value('@name', 'varchar(100)') IN ('duration', 'logical_reads', 'writes','statement')
				) t
			PIVOT (MAX([Result]) FOR [Value] IN ([duration], [logical_reads], [writes], [statement])) p) x2
ORDER BY timestamp_utc DESC

