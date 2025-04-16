-- 30 most recently modified views
SELECT top 30 s.name, v.*
FROM sys.views v
INNER JOIN sys.all_objects o
ON o.object_id=v.object_id
INNER JOIN sys.schemas s
ON o.schema_id=s.schema_id
ORDER BY v.modify_date desc;

-- 30 most recently modified tables
SELECT top 30 s.name, t.*
FROM sys.tables t
INNER JOIN sys.all_objects o
ON o.object_id=t.object_id
INNER JOIN sys.schemas s
ON o.schema_id=s.schema_id
ORDER BY t.modify_date desc;
