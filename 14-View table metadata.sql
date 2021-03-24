
-- New file format
    SHOW FILE FORMATS;

   
-- View table metadata
    SELECT T.TABLE_SCHEMA
            ,T.TABLE_NAME
            ,T.TABLE_TYPE
            ,T.RETENTION_TIME
            ,T.COMMENT
    FROM INFORMATION_SCHEMA.TABLES T
    WHERE T.TABLE_SCHEMA = 'PUBLIC';


-- View table metadata - comments
    SELECT T.TABLE_SCHEMA
            ,T.TABLE_NAME
            ,T.TABLE_TYPE
            ,T.RETENTION_TIME
            ,T.IS_TRANSIENT
            ,T.CLUSTERING_KEY  -- Clustering takes place automatically. Compute credits. 
            ,T.COMMENT
    FROM INFORMATION_SCHEMA.TABLES T
    WHERE T.TABLE_SCHEMA = 'PUBLIC'
    ORDER BY T.TABLE_NAME;
    

-- View column metadata - comments
    SELECT C.TABLE_SCHEMA
            ,C.TABLE_NAME
            ,C.COLUMN_NAME
            ,C.DATA_TYPE
            ,C.COMMENT
    FROM INFORMATION_SCHEMA.COLUMNS C
    WHERE C.TABLE_SCHEMA = 'PUBLIC'
    ORDER BY C.COLUMN_NAME;
    
    
    
    