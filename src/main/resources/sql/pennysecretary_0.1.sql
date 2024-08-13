CREATE TABLE user (
    user_no INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL UNIQUE,
    user_password VARCHAR(255) NOT NULL,
    password_attempts INT DEFAULT 0,
    password_last_changed DATETIME,
    nickname VARCHAR(50) NOT NULL UNIQUE,
    user_name VARCHAR(50) NOT NULL,
    birthdate DATE,
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    signup_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    withdrawal_date DATETIME,
    user_role INT DEFAULT 1 NOT NULL
) CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE lgroup (
    lgroup_no INT AUTO_INCREMENT PRIMARY KEY,
    lgroup_name VARCHAR(100) NOT NULL,
    user_no INT NOT NULL,
    FOREIGN KEY (user_no) REFERENCES user(user_no)
) CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE mgroup (
    mgroup_no INT AUTO_INCREMENT PRIMARY KEY,
    mgroup_name VARCHAR(100) NOT NULL,
    lgroup_no INT NOT NULL,
    FOREIGN KEY (lgroup_no) REFERENCES lgroup(lgroup_no)
) CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE item (
    item_no INT AUTO_INCREMENT PRIMARY KEY,
    lgroup_no INT NOT NULL,
    mgroup_no INT,
    item_name VARCHAR(100) NOT NULL,
    item_image_url VARCHAR(255),
    user_no INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    delete_yn CHAR(1) DEFAULT 'n',
    FOREIGN KEY (lgroup_no) REFERENCES lgroup(lgroup_no),
    FOREIGN KEY (mgroup_no) REFERENCES mgroup(mgroup_no),
    FOREIGN KEY (user_no) REFERENCES user(user_no)
) CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE partners (
    partner_no INT AUTO_INCREMENT PRIMARY KEY,
    partner_name VARCHAR(100) NOT NULL,
    note VARCHAR(255),
    user_no INT NOT NULL,
    FOREIGN KEY (user_no) REFERENCES user(user_no)
) CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE recurring_sett (
    recurring_sett_no INT AUTO_INCREMENT PRIMARY KEY,
    item_no INT NOT NULL,
    user_no INT NOT NULL,
    partner_no INT NOT NULL,
    qa INT NOT NULL,
    recurring_type VARCHAR(50) NOT NULL,
    recurring_value VARCHAR(50) NOT NULL,
    recurring_start_date DATE NOT NULL,
    recurring_end_date DATE NOT NULL,
    note VARCHAR(255),
    FOREIGN KEY (item_no) REFERENCES item(item_no),
    FOREIGN KEY (user_no) REFERENCES user(user_no),
    FOREIGN KEY (partner_no) REFERENCES partners(partner_no)
) CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE trade (
    trade_no INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    qa INT NOT NULL,
    price DECIMAL(10, 2) DEFAULT 0,
    trade_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    ##is_recurring CHAR(1) DEFAULT 'n' NOT NULL,
    recurring_sett_no INT DEFAULT 0 NOT NULL,
    note VARCHAR(255),
    FOREIGN KEY (item_id) REFERENCES item(item_no),
    FOREIGN KEY (recurring_sett_no) REFERENCES recurring_sett(recurring_sett_no)
) CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

show tables;

INSERT INTO user (user_id, user_password, nickname, user_name, phone_number, email)
VALUES 
    ('hyjung', '1234', 'devhyjung', '정하영', '010-0000-0000', 'hyjung@example.com'),
    ('test1', '1234', 'test1', '김철수', '010-1111-1111', 'test1@example.com'),
    ('test2', '1234', 'test2', '이영희', '010-2222-2222', 'test2@example.com'),
    ('test3', '1234', 'test3', '박민수', '010-3333-3333', 'test3@example.com');

INSERT INTO lgroup (lgroup_no, lgroup_name, user_no) VALUES
(1, '정기지출', 1),   -- user_no는 외래키로 NULL로 설정 (필요 시 수정 가능)
(2, '부업', 1),
(3, '기타', 1);

INSERT INTO mgroup (mgroup_no, mgroup_name, lgroup_no) VALUES
(1, '보험비', 1),      -- 대분류 '정기지출' (lgroup_no = 1) 에 속하는 중분류
(2, '보석거래', 2);    -- 대분류 '부업' (lgroup_no = 2) 에 속하는 중분류
use pennysecretary;
select * from user;
select * from lgroup;
select * from mgroup;
## 등록, 조회, 수정, 삭제 로직 만들기 ## 

# 전체 저장 입력받는 값 : 부업 / 보석매매 / 10레벨 멸화 / 1개 / 150000 / 총 금액 / 홍길동 010 4999 2999 / 정기거래여부 x / 거래일시
#             2 / 2 / 10레벨 멸화 / 1 / 
# 대분류, 중분류 생성 로직
# 특이사항 : 1. 대분류는 - 대분류 이름과 유저가 같은경우 저장할 수 없음
#		   2. 중분류 없이 대분류만 저장할 수 있음.



# 입력값 : 대분류 / 중분류 / user_no
INSERT INTO lgroup (lgroup_name, user_no)
	 VALUES ('대분류 이름', 1);
INSERT INTO mgroup (mgroup_name, user_no)
	 VALUES ('중분류 이름', 1);
     
INSERT INTO item (lgroup_no, mgroup_no, item_name, item_image_url, user_no)
	 VALUES (1, 1, "물품 이름", "물품 이미지 url", 1);

INSERT INTO mgroup (mgroup_no, mgroup_name, lgroup_no) VALUES
(1, '보험비', 1),      -- 대분류 '정기지출' (lgroup_no = 1) 에 속하는 중분류
(2, '보석거래', 2);    -- 대분류 '부업' (lgroup_no = 2) 에 속하는 중분류

INSERT INTO item (lgroup_no, mgroup_no, item_name, item_image_url, user_no)
	 VALUES (1, 1, "물품 이름", "물품 이미지 url", 1);



/*
    recurring_sett_no INT AUTO_INCREMENT PRIMARY KEY,
    item_no INT NOT NULL,
    user_no INT NOT NULL,
    partner_no INT NOT NULL,
    qa INT NOT NULL,
    recurring_type VARCHAR(50) NOT NULL,
    recurring_value VARCHAR(50) NOT NULL,
    recurring_start_date DATE NOT NULL,
    recurring_end_date DATE NOT NULL,
    note VARCHAR(255),
    FOREIGN KEY (item_no) REFERENCES item(item_no),
    FOREIGN KEY (user_no) REFERENCES user(user_no),
    FOREIGN KEY (partner_no) REFERENCES partners(partner_no)
*/

select l.lgroup_name lgroup_name, m.mgroup_name, u.user_name from lgroup l, mgroup m, user u where 1=1 and l.lgroup_no = m.mgroup_no and l.user_no = u.user_no
