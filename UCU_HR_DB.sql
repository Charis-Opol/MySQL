
CREATE DATABASE IF NOT EXISTS ucu_hr1;
USE ucu_hr1;

DROP TABLE IF EXISTS AUDIT_LOG;
DROP TABLE IF EXISTS BIODATA;

CREATE TABLE BIODATA (
    biodata_id    INT          AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(80)  NOT NULL,
    last_name     VARCHAR(80)  NOT NULL,
    date_of_birth DATE         NOT NULL,
    gender        ENUM('M','F') NOT NULL,
    national_id   VARCHAR(30)  UNIQUE NOT NULL,
    phone         VARCHAR(20),
    email         VARCHAR(120),
    created_at    DATETIME     DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE AUDIT_LOG (
    log_id      INT          AUTO_INCREMENT PRIMARY KEY,
    action      VARCHAR(50),
    description VARCHAR(200),
    logged_at   DATETIME     DEFAULT CURRENT_TIMESTAMP
);


-- Trigger 1 — BEFORE INSERT
-- Blocks the insert if the person is younger than 18
DROP TRIGGER IF EXISTS trg_biodata_before_insert;

DELIMITER $$
CREATE TRIGGER trg_biodata_before_insert
BEFORE INSERT ON BIODATA
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.date_of_birth, CURDATE()) < 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insert blocked: employee must be at least 18 years old.';
    END IF;
END$$
DELIMITER ;


-- Trigger 2 — AFTER INSERT
-- Logs every new employee addition into AUDIT_LOG
DROP TRIGGER IF EXISTS trg_biodata_after_insert;

DELIMITER $$
CREATE TRIGGER trg_biodata_after_insert
AFTER INSERT ON BIODATA
FOR EACH ROW
BEGIN
    INSERT INTO AUDIT_LOG (action, description)
    VALUES (
        'NEW EMPLOYEE ADDED',
        CONCAT(NEW.first_name, ' ', NEW.last_name, ' (ID: ', NEW.biodata_id, ') was registered.')
    );
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS sp_add_employee;

DELIMITER $$
CREATE PROCEDURE sp_add_employee(
    IN p_first_name    VARCHAR(80),
    IN p_last_name     VARCHAR(80),
    IN p_dob           DATE,
    IN p_gender        ENUM('M','F'),
    IN p_national_id   VARCHAR(30),
    IN p_phone         VARCHAR(20),
    IN p_email         VARCHAR(120)
)
BEGIN
    INSERT INTO BIODATA (first_name, last_name, date_of_birth, gender, national_id, phone, email)
    VALUES (p_first_name, p_last_name, p_dob, p_gender, p_national_id, p_phone, p_email);

    SELECT
        LAST_INSERT_ID()            AS new_biodata_id,
        CONCAT(p_first_name, ' ', p_last_name) AS full_name,
        'Registered successfully'   AS status;
END$$
DELIMITER ;


-- Valid employees (trigger T1 will pass, trigger T2 will log each)
CALL sp_add_employee('Esther',  'Nakato',    '1990-04-15', 'F', 'CM9012345A', '+256700111222', 'nakato@ucu.ac.ug');
CALL sp_add_employee('Brian',   'Ssemakula', '1985-11-03', 'M', 'CM8598765B', '+256782333444', 'brian@ucu.ac.ug');
CALL sp_add_employee('Charis',  'Abenaitwe', '1995-07-20', 'F', 'CM9576543C', '+256701222333', 'charis@ucu.ac.ug');

-- Check the BIODATA table
SELECT * FROM BIODATA;

-- Check the AUDIT_LOG — every insert should appear here
SELECT * FROM AUDIT_LOG;


CALL sp_add_employee('Young', 'Person', '2015-01-01', 'M', 'CM9900001X', '+256700000001', 'young@ucu.ac.ug');