-- Azure Synapse does not provide query store UI in SSMS, use query store catalog views instead
https://learn.microsoft.com/en-us/sql/relational-databases/performance/tune-performance-with-the-query-store?view=azure-sqldw-latest

-- query history (last 96h of query id 641784)
SELECT qt.query_sql_text,
    q.query_id,
    qt.query_text_id,
    p.plan_id,
    rs.runtime_stats_interval_id,
    rs.first_execution_time,
    rs.last_execution_time,
	rs.count_executions,
	rs.avg_duration/1000000 AS "avg_duration(s)",
	rs.min_duration/1000000 AS "min_duration(s)",
	rs.max_duration/1000000 AS "max_duration(s)",
	rs.avg_cpu_time/1000000 AS "cpu_time(s)",
	rs.avg_logical_io_reads,
	rs.avg_logical_io_writes
FROM sys.query_store_query_text AS qt
INNER JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
INNER JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
INNER JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
-- INNER JOIN sys.query_store_wait_stats AS ws
--    ON p.plan_id = ws.plan_id
WHERE rs.last_execution_time > DATEADD(HOUR, -96, GETUTCDATE())
	AND q.query_id=641784
ORDER BY rs.first_execution_time;

-- check wait details
select * from sys.query_store_wait_stats
where plan_id=138844 and runtime_stats_interval_id in (31344,31348,31353,31362,31365)
order by wait_category,runtime_stats_interval_id;

-- check query store status
SELECT name, database_id, is_query_store_on
FROM sys.databases
WHERE name not in ('master','tempdb','model','msdb');

-- enable query store with default settings
USE [master]
GO
ALTER DATABASE [DB_Name] SET QUERY_STORE = ON
GO
ALTER DATABASE [DB_Name] SET QUERY_STORE (OPERATION_MODE = READ_WRITE)
GO

-- current query store settings
SELECT * FROM sys.database_query_store_options;

-- long example
ALTER DATABASE [QueryStoreDB]
SET QUERY_STORE = ON
    (
      OPERATION_MODE = READ_WRITE,
      CLEANUP_POLICY = ( STALE_QUERY_THRESHOLD_DAYS = 90 ),
      DATA_FLUSH_INTERVAL_SECONDS = 900,
      MAX_STORAGE_SIZE_MB = 1000,
      INTERVAL_LENGTH_MINUTES = 60,
      SIZE_BASED_CLEANUP_MODE = AUTO,
      QUERY_CAPTURE_MODE = CUSTOM,
      QUERY_CAPTURE_POLICY = (
        STALE_CAPTURE_POLICY_THRESHOLD = 24 HOURS,
        EXECUTION_COUNT = 30,
        TOTAL_COMPILE_CPU_TIME_MS = 1000,
        TOTAL_EXECUTION_CPU_TIME_MS = 100
      )
    );
