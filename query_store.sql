ALTER DATABASE [db_name] 
SET QUERY_STORE = ON   
    (  
      OPERATION_MODE = READ_WRITE ,
      MAX_STORAGE_SIZE_MB = 1024,
      QUERY_CAPTURE_MODE = AUTO,
      CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 31)
    );