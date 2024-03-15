IF EXISTS (SELECT *
      FROM sys.server_event_sessions
      WHERE name = 'MSSQL_PerformanceAnalyzerEvents')
BEGIN
    DROP EVENT SESSION MSSQL_PerformanceAnalyzerEvents
          ON SERVER;
END
GO

CREATE EVENT SESSION MSSQL_PerformanceAnalyzerEvents
    ON SERVER 
    ADD EVENT sqlserver.sql_statement_completed
    (
        ACTION(sqlserver.database_name)
        WHERE
        ( [sqlserver].[like_i_sql_unicode_string]([sqlserver].[database_name], N'AdventureWorksLT')
        )
    )
    ADD TARGET package0.event_file
    (SET
        filename = N'C:\MSSQL_PerformanceAnalyzer\MSSQL_PerformanceAnalyzer\MSSQL_PerformanceAnalyzerEvents.xel',
        max_file_size = (2),
        max_rollover_files = (2)
    )
    WITH (
        MAX_MEMORY = 2048 KB,
        EVENT_RETENTION_MODE = ALLOW_MULTIPLE_EVENT_LOSS,
        MAX_DISPATCH_LATENCY = 3 SECONDS,
        MAX_EVENT_SIZE = 0 KB,
        MEMORY_PARTITION_MODE = NONE,
        TRACK_CAUSALITY = OFF,
        STARTUP_STATE = ON
    );
GO

ALTER EVENT SESSION MSSQL_PerformanceAnalyzerEvents
      ON SERVER
    STATE = START; -- STOP;