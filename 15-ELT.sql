/* 

	Author: Dan Galavan, www.galavan.com
	
	Release date: 24-Mar-2021 

	Shared under the MIT licence.
	
	Note: 	The source data used in this script - the SNOWFLAKE_SAMPLE_DATABASE and corresponding tables - may
			not be available in all regions. 
			
			It is available in  e.g. Snowflake AWS - EU (Ireland), and Snowflake Azure - West Europe (Netherlands)


	Description: Load data from source to target				
*/

-------------------------------------------------
-- MULTI-TABLE INSERTS
-------------------------------------------------   

	SET REC_SRC = 'SNOWFLAKE_SAMPLE_DATABASE';
    SET TARGET_DB_SCHEMA = 'DEV.PUBLIC';
    
    USE SCHEMA identifier($TARGET_DB_SCHEMA);  

	-- Insert into all tables within the same transation
	-- With Overwrite, Truncation occurs within the same transaction aswell.

-------------------------------------
------- Supplier Hub & Sat
-------------------------------------
		INSERT OVERWRITE ALL                     
			INTO SUPPLIER_H
			VALUES (PK,S_SUPPKEY,CT,RS)
					
			INTO SUPPLIER_S	(SUPPLIER_H_FK, LOAD_DTS, NAME, ADDRESS, PHONE, ACCTBAL, NATIONCODE, HASH_DIFF, REC_SRC)
			VALUES (PK,CT,S_NAME,S_ADDRESS,S_PHONE,S_ACCTBAL,S_NATIONKEY,HASH_DIFF,RS)
								
			SELECT 	MD5(S.S_SUPPKEY) AS PK  -- Add preferred Hashing approach 
					,S.S_SUPPKEY
					,CURRENT_TIMESTAMP() 	CT
					,S_NAME 
					,S_ADDRESS 
					,S_PHONE
					,S_ACCTBAL 
					,S_NATIONKEY 
					,MD5(S_NAME || S_ADDRESS || S_PHONE || S_ACCTBAL || S_NATIONKEY) HASH_DIFF -- Add preferred Hashing approach
					,$REC_SRC				RS
			FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER S;
	
		
		
 --------------------------------
 -- Part Hub & Sat
 --------------------------------
 
		INSERT OVERWRITE ALL 
			
			-- Hub PART_H
				INTO PART_H
				VALUES (PK,P_PARTKEY,CT,RS)
				
			-- Sat PART_S	
				INTO PART_S	(PART_H_FK, LOAD_DTS, PART_NAME, PART_MANUFACTURER, PART_BRAND, PART_TYPE, PART_SIZE, PART_CONTAINER, PART_RETAIL_PRICE,  HASH_DIFF, REC_SRC)
				VALUES (PK,CT,P_NAME,P_MFGR,P_BRAND,P_TYPE,P_SIZE,P_CONTAINER,P_RETAILPRICE,HASH_DIFF,RS)
			
			-- Source		
			SELECT 	MD5(P.P_PARTKEY) AS PK 	-- Add preferred Hashing approach 
					,P.P_PARTKEY
					,CURRENT_TIMESTAMP() 	CT					
					,P.P_NAME 
					,P_MFGR 
					,P_BRAND 
					,P_TYPE 
					,P_SIZE 
					,P_CONTAINER 
					,P_RETAILPRICE 
					
					,MD5(P.P_NAME || P_MFGR || P_BRAND || P_TYPE || P_SIZE || P_CONTAINER || P_RETAILPRICE ) HASH_DIFF -- Add preferred Hashing approach
					,$REC_SRC				RS
				--,'' RS
			FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART P;
        

 --------------------------------
 ---- Inventory Hub, Sat, Link
 --------------------------------
 
			INSERT OVERWRITE ALL 
			INTO SUPPLIER_INVENTORY_H
			VALUES (INVENTORY_PK,INVENTORY_BK,CT,RS)

			INTO SUPPLIER_INVENTORY_S	(INVENTORY_H_PK, LOAD_DTS, SUPPLY_COST, AVAILABLE_QTY, PART_BK, SUPPLIER_BK, HASH_DIFF, REC_SRC)
			VALUES (INVENTORY_PK,CT,PS_SUPPLYCOST,PS_AVAILQTY,PS_PARTKEY,PS_SUPPKEY,HASH_DIFF,RS)					
					
			INTO SUPPLIER_INVENTORY_L	(SUPPLIER_INVENTORY_L_PK, PART_PK, SUPPLIER_PK, INVENTORY_PK, LOAD_DTS, REC_SRC)
			VALUES (INVENTORY_L_PK,PART_PK,SUPPLIER_PK,INVENTORY_PK,CT,RS)

								
			SELECT 	PS_PARTKEY || PS_SUPPKEY 	 					AS INVENTORY_BK
					,MD5(INVENTORY_BK) 								AS INVENTORY_PK 	-- Add preferred Hashing approach
					,MD5(PS_PARTKEY) 			 					AS PART_PK			-- Add preferred Hashing approach
					,MD5(PS_SUPPKEY) 			 					AS SUPPLIER_PK		-- Add preferred Hashing approach
					,MD5(PS_PARTKEY || PS_SUPPKEY || INVENTORY_BK) 	AS INVENTORY_L_PK					
					,PS_AVAILQTY
					,PS_SUPPLYCOST
					,PS_PARTKEY
					,PS_SUPPKEY					
					,MD5(PS_AVAILQTY || PS_SUPPLYCOST) HASH_DIFF	-- Add preferred Hashing approach
					,CURRENT_TIMESTAMP() 	CT					
					,$REC_SRC				RS
					--,'' RS
			FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PARTSUPP P;


    ------------------------------
    -- Weather data
    ------------------------------    

        SET REC_SRC = 'SNOWFLAKE_SAMPLE_DATABASE_WEATHER';

        -- https://openweathermap.org/forecast16#JSON
        USE SCHEMA identifier($TARGET_DB_SCHEMA); 

        USE WAREHOUSE COMPUTE_WH;

        ALTER WAREHOUSE COMPUTE_WH SET WAREHOUSE_SIZE = 'MEDIUM';

        SET REC_SRC = 'SNOWFLAKE_SAMPLE_DATABASE';

        INSERT OVERWRITE ALL 
    ----------------------------------			
    -- Hub - Weather Forecast			
    ----------------------------------
            INTO PUBLIC.WEATHER_FORECAST_H(FORECAST_BK,FORECAST_PK,LOAD_DTS,REC_SRC)			
            VALUES (BK, PK, LOAD_DTS, REC_SRC)

    ----------------------------------
    -- Sat - Weather Forecast	
    ----------------------------------	
            INTO PUBLIC.WEATHER_FORECAST_S (FORECAST_H_FK,LOAD_DTS,COUNTRY_NAME,CITY_NAME, FORECAST_MADE_DTS, FORECAST_ATTRIBUTES,HASH_DIFF,REC_SRC)
            VALUES (PK, LOAD_DTS, COUNTRY_NAME, CITY_NAME, FORECAST_MADE_DTS, VARIANT_PAYLOAD, HASH_DIFF, REC_SRC)	

    ------------------------------		
    -- Source  ("Staging")	
    ------------------------------		        
        SELECT (W.T::STRING || '-' || W.V:city.id::STRING) 	AS BK -- Concatenate JSON timestamp and City ID
                ,MD5(BK)						AS PK -- Add preferred Hashing approach				
                ,CURRENT_TIMESTAMP() 			AS LOAD_DTS	            
                ,W.V:city.country::STRING       AS COUNTRY_NAME             
                ,W.V:city.name::STRING          AS CITY_NAME
                ,w.T 							AS FORECAST_MADE_DTS
                ,w.V							AS VARIANT_PAYLOAD
                ,MD5(w.V)						AS HASH_DIFF
                ,$REC_SRC						AS REC_SRC				
        FROM  "SNOWFLAKE_SAMPLE_DATA"."WEATHER"."DAILY_14_TOTAL" W
        WHERE W.V:city.country::STRING IN ('IE','US')	
            AND w.T > DATEADD(DAY, -1,CURRENT_DATE());

ALTER WAREHOUSE COMPUTE_WH SET WAREHOUSE_SIZE = 'XSMALL';		
        
        
