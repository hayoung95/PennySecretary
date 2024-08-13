CREATE DEFINER=`hyjung`@`%` PROCEDURE `P_RECURRING_TRADE`()
BEGIN
	DECLARE date_json JSON DEFAULT JSON_ARRAY();
	DECLARE recurring_type INT default 1;
    DECLARE recurring_value INT default 5;
    DECLARE recurring_weekday_choice VARCHAR(5) default "weekend";
    DECLARE recurring_start_date DATE default '2024-08-05';
    DECLARE recurring_end_date DATE default '2024-12-29';

	DECLARE update_temp_date DATE;
    DECLARE temp_date DATE;
    
    SET date_json = JSON_ARRAY_APPEND(date_json, '$', recurring_start_date);
    SET temp_date = DATE(CONCAT(YEAR(recurring_start_date),'-', MONTH(recurring_start_date)+1, '-', recurring_value));

	WHILE temp_date < recurring_end_date DO
		CASE
			WHEN recurring_weekday_choice = "monday" AND (WEEKDAY(temp_date) > 4) THEN
				SET update_temp_date = DATE_ADD(temp_date, INTERVAL (7-WEEKDAY(temp_date)) DAY);
                SET date_json = JSON_ARRAY_APPEND(date_json, '$', update_temp_date);
            WHEN recurring_weekday_choice = "friday" AND (WEEKDAY(temp_date) > 4) THEN
				SET update_temp_date = DATE_ADD(temp_date, INTERVAL -(WEEKDAY(temp_date)-4) DAY);
                SET date_json = JSON_ARRAY_APPEND(date_json, '$', update_temp_date);
            ELSE
				SET date_json = JSON_ARRAY_APPEND(date_json, '$', temp_date);
		END CASE;
        
        SET temp_date = DATE_ADD(temp_date, INTERVAL 1 MONTH);
    END WHILE;

END