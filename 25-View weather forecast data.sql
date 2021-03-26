/* 

	Author: Dan Galavan, www.galavan.com
	
	Release date: 24-Mar-2021 

	Notes: 	Shared under the MIT licence.
	
	Description: View weather data
	
*/

   USE SCHEMA LAB_PRELOADED.BIZ;

    SELECT F.*
            ,(F.TEMPERATURE_CELCIUS_DAYTIME * 9/5) + 32 TEMPERATURE_FHT_DAYTIME
    FROM BIZ.VW_OPENWEATHER_FORECAST F 
    WHERE 
        --F.COUNTRY_CODE = 'IE' AND F.CITY = 'Dublin'
        
          F.COUNTRY_CODE = 'US' AND F.CITY = 'San Diego'
          
          AND TO_DATE(F.WEATHER_TIMESTAMP) = '2021-03-24'
          
    ORDER BY WEATHER_TIMESTAMP LIMIT 1;