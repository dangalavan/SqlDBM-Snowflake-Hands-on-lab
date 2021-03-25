/* 

	Author: Dan Galavan, www.galavan.com
	
	Release date: 24-Mar-2021 

	Notes: 	Shared under the MIT licence.
	
*/

-- *********************** SqlDBM: Snowflake ************************
-- ******************************************************************

CREATE SCHEMA IF NOT EXISTS "BIZ";

CREATE SCHEMA IF NOT EXISTS "PUBLIC";

USE DEV;


-- ************************************** "SUPPLIER_INVENTORY_H"
CREATE TABLE IF NOT EXISTS "SUPPLIER_INVENTORY_H"
(
 "INVENTORY_PK" varchar NOT NULL,
 "INVENTORY_BK" varchar NOT NULL,
 "LOAD_DTS"     timestamp NOT NULL,
 "REC_SRC"      varchar NOT NULL,
 CONSTRAINT "PK_inventory_h" PRIMARY KEY ( "INVENTORY_PK" ),
 CONSTRAINT "AK_97" UNIQUE ( "INVENTORY_BK" )
);


-- ************************************** "PUBLIC"."SUPPLIER_H"
CREATE TABLE IF NOT EXISTS "PUBLIC"."SUPPLIER_H"
(
 "SUPPLIER_PK" varchar(16777216) NOT NULL,
 "SUPPLIER_BK" varchar(16777216) NOT NULL,
 "LOAD_DTS"    timestamp_ntz(9) NOT NULL,
 "REC_SRC"     varchar(16777216) NOT NULL,
 CONSTRAINT "PK_supplier_h" PRIMARY KEY ( "SUPPLIER_PK" ),
 CONSTRAINT "AK_98" UNIQUE ( "SUPPLIER_BK" )
);


-- ************************************** "SUPPLIER_H"
CREATE TABLE IF NOT EXISTS "SUPPLIER_H"
(
 "SUPPLIER_PK" varchar NOT NULL COMMENT 'System internal ID',
 "SUPPLIER_BK" varchar NOT NULL COMMENT 'Supplier BK',
 "LOAD_DTS"    timestamp NOT NULL COMMENT 'The date when the data was added to the DV',
 "REC_SRC"     varchar NOT NULL COMMENT 'the data source',
 CONSTRAINT "PK_supplier_h" PRIMARY KEY ( "SUPPLIER_PK" ),
 CONSTRAINT "AK_98" UNIQUE ( "SUPPLIER_BK" )
)
COMMENT = 'The Supplier hub';


-- ************************************** "PART_H"
CREATE TABLE IF NOT EXISTS "PART_H"
(
 "PART_PK"  varchar NOT NULL,
 "PART_BK"  varchar NOT NULL COMMENT 'The part text 23:18',
 "LOAD_DTS" timestamp NOT NULL,
 "REC_SRC"  varchar NOT NULL,
 CONSTRAINT "PK_part_h" PRIMARY KEY ( "PART_PK" ),
 CONSTRAINT "AK_96" UNIQUE ( "PART_BK" )
);




-- ************************************** "PUBLIC"."SUPPLIER_S"
CREATE TABLE IF NOT EXISTS "PUBLIC"."SUPPLIER_S"
(
 "SUPPLIER_H_FK" varchar(16777216) NOT NULL,
 "LOAD_DTS"      timestamp_ntz(9) NOT NULL,
 "NAME"          varchar(16777216),
 "ADDRESS"       varchar(16777216),
 "PHONE"         varchar(16777216),
 "ACCTBAL"       varchar(16777216),
 "NATIONCODE"    varchar(16777216),
 "HASH_DIFF"     varchar(16777216) NOT NULL,
 "REC_SRC"       varchar(16777216) NOT NULL,
 CONSTRAINT "PK_supplier_s" PRIMARY KEY ( "SUPPLIER_H_FK", "LOAD_DTS" ),
 CONSTRAINT "FK_44" FOREIGN KEY ( "SUPPLIER_H_FK" ) REFERENCES "PUBLIC"."SUPPLIER_H" ( "SUPPLIER_PK" )
);


-- ************************************** "SUPPLIER_S"
CREATE TABLE IF NOT EXISTS "SUPPLIER_S"
(
 "SUPPLIER_H_FK" varchar NOT NULL,
 "LOAD_DTS"      timestamp NOT NULL,
 "NAME"          varchar,
 "ADDRESS"       varchar,
 "PHONE"         varchar,
 "ACCTBAL"       varchar,
 "NATIONCODE"    varchar,
 "HASH_DIFF"     varchar NOT NULL,
 "REC_SRC"       varchar NOT NULL,
 CONSTRAINT "PK_supplier_s" PRIMARY KEY ( "SUPPLIER_H_FK", "LOAD_DTS" ),
 CONSTRAINT "FK_44" FOREIGN KEY ( "SUPPLIER_H_FK" ) REFERENCES "SUPPLIER_H" ( "SUPPLIER_PK" )
)
STAGE_FILE_FORMAT = 
(
 FORMAT_NAME = 'FILE_FORMAT_LAB'
)
STAGE_COPY_OPTIONS = 
( 
 ON_ERROR = CONTINUE
 TRUNCATECOLUMNS = TRUE
);


-- ************************************** "SUPPLIER_INVENTORY_S"
CREATE TABLE IF NOT EXISTS "SUPPLIER_INVENTORY_S"
(
 "INVENTORY_H_PK" varchar NOT NULL,
 "LOAD_DTS"       timestamp NOT NULL,
 "SUPPLY_COST"    number(12,2),
 "AVAILABLE_QTY"  number(38,0),
 "PART_BK"        varchar NOT NULL,
 "SUPPLIER_BK"    varchar NOT NULL,
 "HASH_DIFF"      varchar NOT NULL,
 "REC_SRC"        varchar NOT NULL,
 CONSTRAINT "PK_supplier_inventory_s" PRIMARY KEY ( "INVENTORY_H_PK", "LOAD_DTS" ),
 CONSTRAINT "FK_64" FOREIGN KEY ( "INVENTORY_H_PK" ) REFERENCES "SUPPLIER_INVENTORY_H" ( "INVENTORY_PK" )
);


-- ************************************** "SUPPLIER_INVENTORY_L"
CREATE TABLE IF NOT EXISTS "SUPPLIER_INVENTORY_L"
(
 "SUPPLIER_INVENTORY_L_PK" varchar NOT NULL,
 "PART_PK"                 varchar NOT NULL,
 "SUPPLIER_PK"             varchar NOT NULL,
 "INVENTORY_PK"            varchar NOT NULL,
 "LOAD_DTS"                varchar NOT NULL,
 "REC_SRC"                 varchar NOT NULL,
 CONSTRAINT "PK_supplier_inventory_l" PRIMARY KEY ( "SUPPLIER_INVENTORY_L_PK" ),
 CONSTRAINT "FK_77" FOREIGN KEY ( "PART_PK" ) REFERENCES "PART_H" ( "PART_PK" ),
 CONSTRAINT "FK_81" FOREIGN KEY ( "SUPPLIER_PK" ) REFERENCES "SUPPLIER_H" ( "SUPPLIER_PK" ),
 CONSTRAINT "FK_84" FOREIGN KEY ( "INVENTORY_PK" ) REFERENCES "SUPPLIER_INVENTORY_H" ( "INVENTORY_PK" )
);


-- ************************************** "PART_S"
CREATE TABLE IF NOT EXISTS "PART_S"
(
 "PART_H_FK"         varchar NOT NULL,
 "LOAD_DTS"          timestamp NOT NULL,
 "PART_NAME"         varchar,
 "PART_MANUFACTURER" varchar,
 "PART_BRAND"        varchar,
 "PART_TYPE"         varchar,
 "PART_SIZE"         number(10),
 "PART_CONTAINER"    varchar,
 "PART_RETAIL_PRICE" number(12,2),
 "HASH_DIFF"         varchar NOT NULL,
 "REC_SRC"           varchar NOT NULL,
 CONSTRAINT "PK_part_s" PRIMARY KEY ( "PART_H_FK", "LOAD_DTS" ),
 CONSTRAINT "FK_29" FOREIGN KEY ( "PART_H_FK" ) REFERENCES "PART_H" ( "PART_PK" )
)
COMMENT = 'The Parts Satellite.';



-- *********************** SqlDBM: Snowflake ************************
-- ******************************************************************

--USE DEV.PUBLIC
USE DATABASE LAB_PRELOADED;

-- ************************************** "WEATHER_FORECAST_H"
CREATE TABLE IF NOT EXISTS "WEATHER_FORECAST_H"
(
 "FORECAST_PK" varchar NOT NULL,
 "FORECAST_BK" varchar NOT NULL,
 "LOAD_DTS"    timestamp NOT NULL,
 "REC_SRC"     string NOT NULL,
 CONSTRAINT "PK_weather_forecast_h" PRIMARY KEY ( "FORECAST_PK" ),
 CONSTRAINT "UniqueVarBK" UNIQUE ( "FORECAST_BK" )
);


-- ************************************** "WEATHER_FORECAST_S"
CREATE OR REPLACE TABLE "WEATHER_FORECAST_S"
(
 "FORECAST_H_FK"       varchar NOT NULL,
 "LOAD_DTS"            timestamp NOT NULL,
 "FORECAST_MADE_DTS"   timestamp NOT NULL,
 "COUNTRY_NAME"        string NOT NULL,
 "CITY_NAME"           string NOT NULL,
 "FORECAST_ATTRIBUTES" variant NOT NULL,
 "HASH_DIFF"           varchar NOT NULL,
 "REC_SRC"             varchar NOT NULL,
 CONSTRAINT "PK_weather_forecast_s" PRIMARY KEY ( "FORECAST_H_FK", "LOAD_DTS" ),
 CONSTRAINT "FK_113" FOREIGN KEY ( "FORECAST_H_FK" ) REFERENCES "WEATHER_FORECAST_H" ( "FORECAST_PK" )
);





