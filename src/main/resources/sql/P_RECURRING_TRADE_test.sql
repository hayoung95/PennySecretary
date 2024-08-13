CREATE PROCEDURE `P_RECURRING_TRADE` (
	/*
	-- 파라미터 설정
    IN action VARCHAR(5),
    
    -- recurring_sett
    IN recurring_sett_no INT,
    IN item_no INT,
    IN user_no INT,
    IN partner_no INT,
    IN qa INT,
    IN recurring_type VARCHAR(50),
    IN recurring_value VARCHAR(50),
    IN recurring_start_date DATE,
    IN recurring_end_date DATE,
    IN note VARCHAR(255),
    
    -- trade
    IN trade_no INT,
    IN price DECIMAL(10, 2),
    IN trade_date DATETIME
    */
    )
    
BEGIN
	DECLARE date_json JSON DEFAULT JSON_ARRAY();
	DECLARE recurring_type VARCHAR(50) default 1;
    DECLARE recurring_value VARCHAR(50) default 5;
    DECLARE recurring_weekday_choice VARCHAR(5) default "weekend";
    DECLARE recurring_start_date DATE default '2024-08-05';
    DECLARE recurring_end_date DATE default '2024-12-29';
    
    DECLARE update_current_date DATE;
    DECLARE current_date DATE;
    -- recurring_type값에 따른 분류
    -- 1 : 매월 n일에 결제
    -- 2 : n일 주기로 결제
    -- 3 : 매주 n째주 n요일에 결제
    -- 4 : 매월 첫날에 결제
    /*
    반복거래일과 거래일 이 두가지인데,
    반복거래일이 있는경우, 거래일은 없다.
    이게맞는듯?
    아니면
    시작일을 두고 거래일을 없애자.
    그러면 한달에 거래가 2개생길 일은 없음.
    이번달은 오늘
    다음달부터는 n일의 개념이다.
    이건 사용자가 아무일이나 선택할게아니라 금월에는 특정일에 결제하고, 차월부터 해당 결제일에 거래를 한다는 의미로 받아들이면됌
    그럼 결국. 시작은 다음달부터네 가아니고
    current로 하나 뽑아서 바로보내고, 
    아니면 그냥 디폴트로 박자. 첫일을 디폴트로 박고 재생일부터 적용한다.
    */
    SET date_json = JSON_ARRAY_APPEND(recurring_start_date);
    SET current_date = DATE(CONCAT(YEAR(recurring_start_date),'-', MONTH(recurring_start_date)+1, '-', recurring_value));
	CASE
		WHEN current_date = '' THEN
        SET current_date = '';
    END CASE;
	WHILE current_date < recurring_end_date DO
		CASE
			WHEN recurring_weekday_choice = "monday" AND (WEEKDAY(current_date) > 4) THEN
				SET update_current_date = DATE_ADD(current_date, INTERVAL (7-WEEKDAY(current_date)) DAY);
                SET date_json = JSON_ARRAY_APPEND(date_json, '$', update_current_date);
            WHEN recurring_weekday_choice = "friday" AND (WEEKDAY(current_date) > 4) THEN
				SET update_current_date = DATE_ADD(current_date, INTERVAL -(WEEKDAY(current_date)-4) DAY);
                SET date_json = JSON_ARRAY_APPEND(date_json, '$', update_current_date);
            ELSE
				SET date_json = JSON_ARRAY_APPEND(date_json, '$', current_date);
		END CASE;
        
        SET current_Date = DATE_ADD(current_date, INTERVAL 1 MONTH);
    END WHILE;
END

/*
    recurring_sett_no INT AUTO_INCREMENT PRIMARY KEY,
    item_no INT,
    user_no INT,
    partner_no INT,
    qa INT,
    recurring_type VARCHAR(50),
    recurring_value VARCHAR(50),
    recurring_start_date DATE,
    recurring_end_date DATE,
    note VARCHAR(255),
    FOREIGN KEY (item_no) REFERENCES item(item_no),
    FOREIGN KEY (user_no) REFERENCES user(user_no),
    FOREIGN KEY (partner_no) REFERENCES partners(partner_no)
    
    CREATE TABLE trade (
    trade_no INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT,
    qa INT,
    price DECIMAL(10, 2) DEFAULT 0,
    trade_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    ##is_recurring CHAR(1) DEFAULT 'n',
    recurring_sett_no INT DEFAULT 0,
    note VARCHAR(255),
    FOREIGN KEY (item_id) REFERENCES item(item_no),
    FOREIGN KEY (recurring_sett_no) REFERENCES recurring_sett(recurring_sett_no)
) CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
*/