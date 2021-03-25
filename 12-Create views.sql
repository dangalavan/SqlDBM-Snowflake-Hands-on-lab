/* 

	Author: Dan Galavan, www.galavan.com
	
	Release date: 24-Mar-2021 

	Notes: 	Shared under the MIT licence.
	
*/

CREATE SCHEMA IF NOT EXISTS BIZ;

Create OR REPLACE View BIZ.VW_OPENWEATHER_FORECAST

  Comment = 'Open Weather Map data'

AS
(
  	SELECT S.FORECAST_H_FK 

			,S.COUNTRY_NAME		                            COUNTRY_CODE
			,S.CITY_NAME 		                            CITY
			,TO_TIMESTAMP(D.value:dt::STRING)				Weather_TIMESTAMP			

			,(D.value:temp.day::decimal(10,2) - 273.15)  	TEMPERATURE_CELCIUS_DAYTIME -- convert Kelvin to Celcius
			,(D.value:temp.min::decimal(10,2) - 273.15)  	TEMPERATURE_CELCIUS_MIN		-- convert Kelvin to Celcius
			,(D.value:temp.max::decimal(10,2) - 273.15)  	TEMPERATURE_CELCIUS_MAX		-- convert Kelvin to Celcius						
		
			,W.value:description::STRING 					WEATHER_DESCRIPTION

	FROM "PUBLIC".WEATHER_FORECAST_S S
		,LATERAL FLATTEN (input => S.FORECAST_ATTRIBUTES, path => 'data') D
		,LATERAL FLATTEN (INPUT => D.value:weather) W

	WHERE S.FORECAST_MADE_DTS > (DATEADD(month,-6, CURRENT_TIMESTAMP()))
	ORDER BY S.FORECAST_MADE_DTS DESC, Weather_TIMESTAMP DESC
);


select * FROM "PUBLIC".WEATHER_FORECAST_S S LIMIT 4;


