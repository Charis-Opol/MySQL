-- ================================================================
--   UCU HR DATABASE — COMPLETE STORED PROCEDURES & TRIGGERS
--   Based on the full EERD (UCU_HR_Database_EERD_drawio.png)
--
--   ENTITIES COVERED:
--     EMPLOYEE, BIO_DATA, FINANCIAL_DATA, QUALIFICATIONS,
--     DIVISION, FACULTY, DEPARTMENT, POSITION,
--     PROBATION, PERFORMANCE_EVALUATIONS,
--     LEAVE, LEAVE_TYPE, TRAINING_AND_DEVELOPMENT,
--     SEPARATION_RECORD, DISCIPLINARY_RECORD,
--     ACADEMIC_STAFF, ADMINISTRATIVE_STAFF, AUDIT_LOG
-- ================================================================


-- ================================================================
-- SECTION 1: DATABASE SETUP
-- ================================================================

CREATE DATABASE IF NOT EXISTS ucu_hr_db;
USE ucu_hr_db;


-- ================================================================
-- SECTION 2: TABLE DEFINITIONS
--   Every table is derived directly from the ERD entities and
--   their visible attributes. Foreign keys enforce relationships.
-- ================================================================

-- ----------------------------------------------------------------
-- BIO_DATA — personal/biographical information
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BIO_DATA (
    BIO_DATA_ID           INT PRIMARY KEY AUTO_INCREMENT,
    FIRST_NAME            VARCHAR(50)  NOT NULL,
    LAST_NAME             VARCHAR(50)  NOT NULL,
    DOB                   DATE,
    GENDER                CHAR(1),                 -- 'M' or 'F'
    NATIONAL_ID           VARCHAR(20)  UNIQUE,
    EMAIL                 VARCHAR(100) UNIQUE,
    PHONE_NUMBER          VARCHAR(20),
    HOME_RESIDENCE        VARCHAR(100),
    CURRENT_RESIDENCE     VARCHAR(100),
    SPOUSE_NAME           VARCHAR(100),
    NUMBER_OF_CHILDREN    INT          DEFAULT 0,
    NEXT_OF_KIN           VARCHAR(100),
    NEXT_OF_KIN_PHONE     VARCHAR(20),
    NEXT_OF_KIN_RELATION  VARCHAR(50)
);

-- ----------------------------------------------------------------
-- DIVISION — top-level organisational unit
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS DIVISION (
    DIVISION_ID    INT PRIMARY KEY AUTO_INCREMENT,
    DIVISION_NAME  VARCHAR(100) NOT NULL
);

-- ----------------------------------------------------------------
-- FACULTY — belongs to a DIVISION (M:1)
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS FACULTY (
    FACULTY_ID    INT PRIMARY KEY AUTO_INCREMENT,
    DIVISION_ID   INT          NOT NULL,
    FACULTY_NAME  VARCHAR(100) NOT NULL,
    FACULTY_TYPE  VARCHAR(50),
    FOREIGN KEY (DIVISION_ID) REFERENCES DIVISION(DIVISION_ID)
);

-- ----------------------------------------------------------------
-- DEPARTMENT — belongs to a FACULTY (M:1), managed by an employee
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS DEPARTMENT (
    DEPARTMENT_ID    INT PRIMARY KEY AUTO_INCREMENT,
    FACULTY_ID       INT,
    DEPARTMENT_NAME  VARCHAR(100) NOT NULL,
    OFFICE_LOCATION  VARCHAR(100),
    FOREIGN KEY (FACULTY_ID) REFERENCES FACULTY(FACULTY_ID)
);

-- ----------------------------------------------------------------
-- POSITION — a job role that an employee can occupy
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS POSITION (
    POSITION_ID           INT PRIMARY KEY AUTO_INCREMENT,
    POSITION_TITLE        VARCHAR(100) NOT NULL,
    DESCRIPTION           TEXT,
    RANK                  VARCHAR(50),             -- e.g. Grade 1-4
    CONTRACT_DURATION_YEARS INT DEFAULT 2
);

-- ----------------------------------------------------------------
-- FINANCIAL_DATA — payroll and banking details
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS FINANCIAL_DATA (
    FINANCIAL_ID      INT PRIMARY KEY AUTO_INCREMENT,
    EMPLOYEE_ID       INT          NOT NULL,
    BANK_NAME         VARCHAR(100),
    ACCOUNT_NUMBER    VARCHAR(30),
    NSSF_NUMBER       VARCHAR(30),
    NSSF_RATE         DECIMAL(5,2) DEFAULT 10.00,  -- employer % contribution
    SALARY            DECIMAL(12,2) NOT NULL,
    COUNCIL_APPROVAL  VARCHAR(50)
);

-- ----------------------------------------------------------------
-- QUALIFICATIONS — academic/professional credentials
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS QUALIFICATIONS (
    QUALIFICATION_ID    INT PRIMARY KEY AUTO_INCREMENT,
    EMPLOYEE_ID         INT NOT NULL,
    FIELD_OF_STUDY      VARCHAR(100),
    PROGRAMME_NAME      VARCHAR(100),
    GRADUATION_YEAR     YEAR,
    CERTIFICATE_NUMBER  VARCHAR(50),
    PUBLICATIONS_COUNT  INT DEFAULT 0,
    YEARS_OF_EXPERIENCE INT DEFAULT 0
);

-- ----------------------------------------------------------------
-- EMPLOYEE — the central entity
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS EMPLOYEE (
    EMPLOYEE_ID           INT PRIMARY KEY AUTO_INCREMENT,
    BIO_DATA_ID           INT UNIQUE,           -- 1:1 with BIO_DATA
    FINANCIAL_ID          INT,                  -- 1:1 with FINANCIAL_DATA
    DEPARTMENT_ID         INT,
    POSITION_ID           INT,
    EMPLOYEE_CATEGORY_ID  INT,                  -- academic / admin / etc.
    SUPERVISOR_ID         INT,                  -- self-referencing: the manager
    HIRE_DATE             DATE         NOT NULL,
    WORK_EMAIL            VARCHAR(100) UNIQUE,
    EMPLOYEE_RANK         VARCHAR(50),
    CONTRACT_START_DATE   DATE,
    CHRISTIAN_COMMITMENT  VARCHAR(100),

    FOREIGN KEY (BIO_DATA_ID)  REFERENCES BIO_DATA(BIO_DATA_ID),
    FOREIGN KEY (FINANCIAL_ID) REFERENCES FINANCIAL_DATA(FINANCIAL_ID),
    FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENT(DEPARTMENT_ID),
    FOREIGN KEY (POSITION_ID)  REFERENCES POSITION(POSITION_ID),
    FOREIGN KEY (SUPERVISOR_ID) REFERENCES EMPLOYEE(EMPLOYEE_ID)
);

-- ----------------------------------------------------------------
-- ACADEMIC_STAFF — specialisation of EMPLOYEE (IS-A)
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ACADEMIC_STAFF (
    EMPLOYEE_ID              INT PRIMARY KEY,
    YEARS_TEACHING_EXPERIENCE INT DEFAULT 0,
    PUBLICATIONS_COUNT        INT DEFAULT 0,
    ACADEMIC_RANK             VARCHAR(50),
    PHD_REQUIREMENT_CONTRACT  VARCHAR(100),   -- e.g. 'Within 5 years'
    FOREIGN KEY (EMPLOYEE_ID) REFERENCES EMPLOYEE(EMPLOYEE_ID)
);

-- ----------------------------------------------------------------
-- ADMINISTRATIVE_STAFF — specialisation of EMPLOYEE (IS-A)
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ADMINISTRATIVE_STAFF (
    EMPLOYEE_ID   INT PRIMARY KEY,
    FOREIGN KEY (EMPLOYEE_ID) REFERENCES EMPLOYEE(EMPLOYEE_ID)
);

-- ----------------------------------------------------------------
-- PROBATION — tracks new employee probationary period
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS PROBATION (
    PROBATION_ID        INT PRIMARY KEY AUTO_INCREMENT,
    EMPLOYEE_ID         INT NOT NULL,
    START_DATE          DATE,
    END_DATE            DATE,
    EVALUATION_SCORE    DECIMAL(5,2),
    PROBATION_STATUS    VARCHAR(30) DEFAULT 'ONGOING', -- ONGOING/PASSED/FAILED
    FOREIGN KEY (EMPLOYEE_ID) REFERENCES EMPLOYEE(EMPLOYEE_ID)
);

-- ----------------------------------------------------------------
-- PERFORMANCE_EVALUATIONS — annual / periodic reviews
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS PERFORMANCE_EVALUATIONS (
    EVALUATION_ID             INT PRIMARY KEY AUTO_INCREMENT,
    EMPLOYEE_ID               INT NOT NULL,
    SUPERVISOR_ID             INT,
    EVALUATION_DATE           DATE,
    EVALUATION_PERIOD         VARCHAR(50),       -- e.g. 'FY 2024'
    DIRECTION_OF_PASTOR_SCORE DECIMAL(5,2),
    INNOVATION_SCORE          DECIMAL(5,2),
    TEAMWORK_SCORE            DECIMAL(5,2),
    CHRISTIAN_VALUES_SCORE    DECIMAL(5,2),
    SERVICE_DELIVERY_SCORE    DECIMAL(5,2),
    TOTAL_SCORE               DECIMAL(5,2),
    HRA_FORM_COMPLETED        TINYINT(1) DEFAULT 0, -- 0=No, 1=Yes
    FOREIGN KEY (EMPLOYEE_ID)  REFERENCES EMPLOYEE(EMPLOYEE_ID),
    FOREIGN KEY (SUPERVISOR_ID) REFERENCES EMPLOYEE(EMPLOYEE_ID)
);

-- ----------------------------------------------------------------
-- LEAVE_TYPE — defines the types of leave available at UCU
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS LEAVE_TYPE (
    LEAVE_ID          INT PRIMARY KEY AUTO_INCREMENT,
    LEAVE_TYPE        VARCHAR(50) NOT NULL,  -- Annual, Sick, Maternity, etc.
    DAYS_ENTITLEMENT  INT,
    CARRY_OVER_DAYS   INT DEFAULT 0,
    FULL_PAY_MONTHS   INT DEFAULT 0,
    HALF_PAY_MONTHS   INT DEFAULT 0,
    MEDICAL_CERT_REQUIRED TINYINT(1) DEFAULT 0
);

-- ----------------------------------------------------------------
-- LEAVE — a leave application/record per employee
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS LEAVE_RECORD (
    LEAVE_RECORD_ID          INT PRIMARY KEY AUTO_INCREMENT,
    EMPLOYEE_ID              INT NOT NULL,
    LEAVE_ID                 INT NOT NULL,   -- FK to LEAVE_TYPE
    START_DATE               DATE,
    END_DATE                 DATE,
    REASON                   TEXT,
    STATUS                   VARCHAR(20) DEFAULT 'PENDING', -- PENDING/APPROVED/REJECTED
    APPROVED_BY              INT,            -- FK to EMPLOYEE (approver)
    RELEASE_DATE             DATE,
    DAYS_USED                INT,
    MEDICAL_CLEARANCE_REQUIRED TINYINT(1) DEFAULT 0,
    -- Maternity-specific fields
    MATERNITY_START          DATE,
    EXPECTED_DELIVERY_DATE   DATE,
    -- Sabbatical-specific fields
    YEARS_SERVICE_AT_REQUEST INT,
    SABBATICAL_START         DATE,
    COUNCIL_APPROVED         TINYINT(1) DEFAULT 0,
    FOREIGN KEY (EMPLOYEE_ID) REFERENCES EMPLOYEE(EMPLOYEE_ID),
    FOREIGN KEY (LEAVE_ID)    REFERENCES LEAVE_TYPE(LEAVE_ID),
    FOREIGN KEY (APPROVED_BY) REFERENCES EMPLOYEE(EMPLOYEE_ID)
);

-- ----------------------------------------------------------------
-- TRAINING_AND_DEVELOPMENT — courses / programmes attended
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS TRAINING_AND_DEVELOPMENT (
    DEVELOPMENT_ID     INT PRIMARY KEY AUTO_INCREMENT,
    EMPLOYEE_ID        INT NOT NULL,
    START_DATE         DATE,
    END_DATE           DATE,
    TODAY_DATE         DATE,                 -- date record was entered
    TRAINING_DATE      DATE,
    APPROVED_BY        INT,
    DEVELOPMENT_TYPE   VARCHAR(100),         -- e.g. 'Short Course', 'Conference'
    INSTITUTION        VARCHAR(100),
    BOND_REQUIRED      TINYINT(1) DEFAULT 0, -- 1 = employee must serve after training
    BONDING_PERIOD_MONTHS INT DEFAULT 0,
    FOREIGN KEY (EMPLOYEE_ID) REFERENCES EMPLOYEE(EMPLOYEE_ID),
    FOREIGN KEY (APPROVED_BY) REFERENCES EMPLOYEE(EMPLOYEE_ID)
);

-- ----------------------------------------------------------------
-- SEPARATION_RECORD — records when/how an employee leaves UCU
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS SEPARATION_RECORD (
    SEPARATION_ID              INT PRIMARY KEY AUTO_INCREMENT,
    EMPLOYEE_ID                INT NOT NULL,
    SEPARATION_TYPE            VARCHAR(50),     -- Resignation, Dismissal, Retirement
    EFFECTIVE_DATE             DATE,
    NOTICE_PERIOD_DAYS         INT,
    EXIT_CLEARANCE_COMPLETE    TINYINT(1) DEFAULT 0,
    CERTIFICATE_OF_SERVICE_ISSUED TINYINT(1) DEFAULT 0,
    SEVERANCE_PAY_AMOUNT       DECIMAL(12,2) DEFAULT 0,
    TERMINAL_APPROVED          TINYINT(1) DEFAULT 0,
    HRA_APPROVED               TINYINT(1) DEFAULT 0,
    PROCESSED_BY               INT,             -- HR officer FK
    FOREIGN KEY (EMPLOYEE_ID)  REFERENCES EMPLOYEE(EMPLOYEE_ID),
    FOREIGN KEY (PROCESSED_BY) REFERENCES EMPLOYEE(EMPLOYEE_ID)
);

-- ----------------------------------------------------------------
-- DISCIPLINARY_RECORD — misconduct and sanctions
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS DISCIPLINARY_RECORD (
    DISCIPLINARY_ID      INT PRIMARY KEY AUTO_INCREMENT,
    EMPLOYEE_ID          INT NOT NULL,
    ISSUED_BY            INT,                 -- supervisor/HR officer FK
    OFFENCE_DESCRIPTION  TEXT,
    CATEGORY             VARCHAR(50),         -- Minor / Major / Gross
    SANCTION_ISSUED      VARCHAR(100),        -- Warning, Suspension, Dismissal
    DATE_ISSUED          DATE,
    CRIMINAL_PROCEEDING  TINYINT(1) DEFAULT 0, -- 1 = case referred to courts
    APPEAL_LODGED        TINYINT(1) DEFAULT 0,
    FOREIGN KEY (EMPLOYEE_ID) REFERENCES EMPLOYEE(EMPLOYEE_ID),
    FOREIGN KEY (ISSUED_BY)   REFERENCES EMPLOYEE(EMPLOYEE_ID)
);

-- ----------------------------------------------------------------
-- AUDIT_LOG — automatic change tracking (used by all triggers)
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS AUDIT_LOG (
    LOG_ID       INT PRIMARY KEY AUTO_INCREMENT,
    TABLE_NAME   VARCHAR(50),
    ACTION_TYPE  VARCHAR(10),               -- INSERT / UPDATE / DELETE
    RECORD_ID    INT,
    CHANGED_BY   VARCHAR(100) DEFAULT USER(),
    CHANGED_AT   DATETIME     DEFAULT NOW(),
    DESCRIPTION  TEXT
);


-- ================================================================
-- SECTION 3: STORED PROCEDURES
--
-- A stored procedure is a saved, reusable block of SQL.
-- You call it by name like: CALL procedure_name(args);
-- It can accept input parameters (IN) and return results.
-- ================================================================

DELIMITER $$


-- ----------------------------------------------------------------
-- PROCEDURE 1: sp_register_employee
-- What it does: Full onboarding — creates bio data, financial
--   record, and the main employee row in one transaction.
-- A TRANSACTION means all steps either succeed together or
--   all roll back (undo) if anything fails. This protects data.
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_register_employee (
    -- Personal details (IN = value passed in by the caller)
    IN p_first_name     VARCHAR(50),
    IN p_last_name      VARCHAR(50),
    IN p_dob            DATE,
    IN p_gender         CHAR(1),
    IN p_national_id    VARCHAR(20),
    IN p_email          VARCHAR(100),
    IN p_phone          VARCHAR(20),
    -- Job details
    IN p_hire_date      DATE,
    IN p_department_id  INT,
    IN p_position_id    INT,
    IN p_supervisor_id  INT,
    -- Financial details
    IN p_salary         DECIMAL(12,2),
    IN p_bank_name      VARCHAR(100),
    IN p_account_number VARCHAR(30),
    IN p_nssf_number    VARCHAR(30)
)
BEGIN
    -- Declare local variables to hold auto-generated IDs
    DECLARE v_bio_id       INT;
    DECLARE v_financial_id INT;
    DECLARE v_employee_id  INT;

    -- DECLARE CONTINUE HANDLER catches any SQL error so we can ROLLBACK
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- undo everything if any step fails
        SELECT 'ERROR: Registration failed. All changes have been rolled back.' AS status;
    END;

    -- START TRANSACTION groups all inserts into one atomic unit
    START TRANSACTION;

        -- STEP 1: Insert biographical data
        -- This creates the personal profile first
        INSERT INTO BIO_DATA (
            FIRST_NAME, LAST_NAME, DOB, GENDER,
            NATIONAL_ID, EMAIL, PHONE_NUMBER
        )
        VALUES (
            p_first_name, p_last_name, p_dob, p_gender,
            p_national_id, p_email, p_phone
        );
        -- LAST_INSERT_ID() returns the auto-generated primary key
        -- from the most recent INSERT in this session
        SET v_bio_id = LAST_INSERT_ID();

        -- STEP 2: Create the financial record
        -- EMPLOYEE_ID is set to 0 temporarily; updated below
        INSERT INTO FINANCIAL_DATA (
            EMPLOYEE_ID, SALARY, BANK_NAME, ACCOUNT_NUMBER, NSSF_NUMBER
        )
        VALUES (0, p_salary, p_bank_name, p_account_number, p_nssf_number);

        SET v_financial_id = LAST_INSERT_ID();

        -- STEP 3: Create the main employee record
        -- This links all the pieces together via foreign keys
        INSERT INTO EMPLOYEE (
            BIO_DATA_ID, FINANCIAL_ID, DEPARTMENT_ID, POSITION_ID,
            SUPERVISOR_ID, HIRE_DATE, WORK_EMAIL
        )
        VALUES (
            v_bio_id, v_financial_id, p_department_id, p_position_id,
            p_supervisor_id, p_hire_date,
            CONCAT(LOWER(p_first_name), '.', LOWER(p_last_name), '@ucu.ac.ug')
        );
        SET v_employee_id = LAST_INSERT_ID();

        -- STEP 4: Fix the FINANCIAL_DATA row with the real employee ID
        UPDATE FINANCIAL_DATA
        SET EMPLOYEE_ID = v_employee_id
        WHERE FINANCIAL_ID = v_financial_id;

        -- STEP 5: Create a probation record automatically for all new hires
        -- UCU policy: 6-month probation (END_DATE = HIRE_DATE + 6 months)
        INSERT INTO PROBATION (EMPLOYEE_ID, START_DATE, END_DATE, PROBATION_STATUS)
        VALUES (
            v_employee_id,
            p_hire_date,
            DATE_ADD(p_hire_date, INTERVAL 6 MONTH),  -- adds 6 months to hire date
            'ONGOING'
        );

    -- COMMIT saves all the changes permanently
    COMMIT;

    -- Return a success summary to the caller
    SELECT
        v_employee_id  AS new_employee_id,
        p_first_name   AS first_name,
        p_last_name    AS last_name,
        p_hire_date    AS hire_date,
        DATE_ADD(p_hire_date, INTERVAL 6 MONTH) AS probation_end_date,
        'Employee successfully registered' AS status;

END$$


-- ----------------------------------------------------------------
-- PROCEDURE 2: sp_get_full_employee_profile
-- What it does: Returns a complete employee profile by joining
--   all related tables. Useful for HR dashboards and reports.
-- JOIN = combine rows from multiple tables where keys match.
-- LEFT JOIN = include the employee even if a linked record is missing.
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_get_full_employee_profile (
    IN p_employee_id INT
)
BEGIN
    SELECT
        -- Employee core fields
        e.EMPLOYEE_ID,
        e.HIRE_DATE,
        e.WORK_EMAIL,
        e.EMPLOYEE_RANK,
        e.CONTRACT_START_DATE,
        e.CHRISTIAN_COMMITMENT,

        -- Bio data (personal info)
        b.FIRST_NAME,
        b.LAST_NAME,
        CONCAT(b.FIRST_NAME, ' ', b.LAST_NAME) AS full_name,
        b.DOB,
        -- TIMESTAMPDIFF calculates completed years between DOB and today
        TIMESTAMPDIFF(YEAR, b.DOB, CURDATE())  AS age,
        b.GENDER,
        b.NATIONAL_ID,
        b.EMAIL            AS personal_email,
        b.PHONE_NUMBER,
        b.SPOUSE_NAME,
        b.NUMBER_OF_CHILDREN,
        b.NEXT_OF_KIN,
        b.NEXT_OF_KIN_PHONE,

        -- Organisational placement
        dept.DEPARTMENT_NAME,
        fac.FACULTY_NAME,
        div.DIVISION_NAME,
        pos.POSITION_TITLE,
        pos.RANK           AS position_grade,

        -- Financial info
        f.SALARY,
        f.BANK_NAME,
        f.ACCOUNT_NUMBER,
        f.NSSF_NUMBER,

        -- Supervisor name (self-join: join EMPLOYEE to itself to get manager)
        CONCAT(sb.FIRST_NAME, ' ', sb.LAST_NAME) AS supervisor_name,

        -- Probation status
        pr.PROBATION_STATUS,
        pr.END_DATE        AS probation_end_date

    FROM EMPLOYEE e
    -- Join personal data
    LEFT JOIN BIO_DATA          b    ON e.BIO_DATA_ID    = b.BIO_DATA_ID
    -- Join financial data
    LEFT JOIN FINANCIAL_DATA    f    ON e.FINANCIAL_ID   = f.FINANCIAL_ID
    -- Join department
    LEFT JOIN DEPARTMENT        dept ON e.DEPARTMENT_ID  = dept.DEPARTMENT_ID
    -- Join faculty through department
    LEFT JOIN FACULTY           fac  ON dept.FACULTY_ID  = fac.FACULTY_ID
    -- Join division through faculty
    LEFT JOIN DIVISION          div  ON fac.DIVISION_ID  = div.DIVISION_ID
    -- Join position
    LEFT JOIN POSITION          pos  ON e.POSITION_ID    = pos.POSITION_ID
    -- Join supervisor: get the supervisor's EMPLOYEE row, then their BIO_DATA
    LEFT JOIN EMPLOYEE          sup  ON e.SUPERVISOR_ID  = sup.EMPLOYEE_ID
    LEFT JOIN BIO_DATA          sb   ON sup.BIO_DATA_ID  = sb.BIO_DATA_ID
    -- Join latest probation record
    LEFT JOIN PROBATION         pr   ON e.EMPLOYEE_ID    = pr.EMPLOYEE_ID

    WHERE e.EMPLOYEE_ID = p_employee_id;

END$$


-- ----------------------------------------------------------------
-- PROCEDURE 3: sp_update_salary
-- What it does: Updates an employee's salary, validates the
--   change, and logs it for audit. Rejects invalid amounts.
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_update_salary (
    IN p_employee_id INT,
    IN p_new_salary  DECIMAL(12,2)
)
BEGIN
    DECLARE v_old_salary DECIMAL(12,2);

    -- Fetch the current salary into our local variable
    SELECT SALARY INTO v_old_salary
    FROM FINANCIAL_DATA
    WHERE EMPLOYEE_ID = p_employee_id;

    -- Validate: employee must exist in financial records
    IF v_old_salary IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: No financial record found for this employee.';
    END IF;

    -- Validate: new salary must be at least UGX 300,000 (minimum wage policy)
    IF p_new_salary < 300000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Salary cannot be below UGX 300,000 minimum.';
    END IF;

    -- Validate: salary reductions require formal HR process, block here
    IF p_new_salary < v_old_salary THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Salary reduction not permitted via this procedure. Raise an HR request.';
    END IF;

    -- All checks passed — perform the update
    UPDATE FINANCIAL_DATA
    SET SALARY = p_new_salary
    WHERE EMPLOYEE_ID = p_employee_id;

    -- Log the change in AUDIT_LOG for compliance/traceability
    -- CONCAT builds a single string from multiple parts
    -- FORMAT(number, 2) adds comma separators: 2,500,000.00
    INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
    VALUES (
        'FINANCIAL_DATA', 'UPDATE', p_employee_id,
        CONCAT('Salary updated: UGX ', FORMAT(v_old_salary,2),
               ' → UGX ', FORMAT(p_new_salary,2))
    );

    -- Return confirmation to the caller
    SELECT p_employee_id AS employee_id,
           v_old_salary  AS old_salary,
           p_new_salary  AS new_salary,
           'Salary updated successfully' AS status;

END$$


-- ----------------------------------------------------------------
-- PROCEDURE 4: sp_apply_leave
-- What it does: Employee applies for leave. Checks they have
--   not exceeded their entitlement before approving.
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_apply_leave (
    IN p_employee_id  INT,
    IN p_leave_id     INT,        -- type of leave
    IN p_start_date   DATE,
    IN p_end_date     DATE,
    IN p_reason       TEXT
)
BEGIN
    DECLARE v_days_requested  INT;
    DECLARE v_days_entitlement INT;
    DECLARE v_days_used_so_far INT;
    DECLARE v_days_remaining   INT;

    -- Calculate how many days this leave request covers
    -- DATEDIFF returns the difference in days between two dates
    SET v_days_requested = DATEDIFF(p_end_date, p_start_date) + 1;

    -- Get the entitlement for this leave type
    SELECT DAYS_ENTITLEMENT INTO v_days_entitlement
    FROM LEAVE_TYPE
    WHERE LEAVE_ID = p_leave_id;

    -- Sum how many days of this leave type the employee has already used
    -- COALESCE returns the first non-NULL value — handles no prior records
    SELECT COALESCE(SUM(DAYS_USED), 0) INTO v_days_used_so_far
    FROM LEAVE_RECORD
    WHERE EMPLOYEE_ID = p_employee_id
      AND LEAVE_ID    = p_leave_id
      AND STATUS      = 'APPROVED'
      AND YEAR(START_DATE) = YEAR(CURDATE()); -- only count this calendar year

    SET v_days_remaining = v_days_entitlement - v_days_used_so_far;

    -- If the employee doesn't have enough leave days left, reject the request
    IF v_days_requested > v_days_remaining THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Insufficient leave days remaining for this request.';
    END IF;

    -- Insert the leave application with PENDING status
    INSERT INTO LEAVE_RECORD (
        EMPLOYEE_ID, LEAVE_ID, START_DATE, END_DATE,
        REASON, STATUS, DAYS_USED
    )
    VALUES (
        p_employee_id, p_leave_id, p_start_date, p_end_date,
        p_reason, 'PENDING', v_days_requested
    );

    -- Confirm the application to the caller
    SELECT
        LAST_INSERT_ID()   AS leave_record_id,
        v_days_requested   AS days_requested,
        v_days_remaining   AS days_remaining_before_approval,
        'Leave application submitted — awaiting approval' AS status;

END$$


-- ----------------------------------------------------------------
-- PROCEDURE 5: sp_approve_leave
-- What it does: HR/supervisor approves or rejects a leave request.
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_approve_leave (
    IN p_leave_record_id INT,
    IN p_approved_by     INT,      -- employee ID of the approver
    IN p_decision        VARCHAR(10)  -- 'APPROVED' or 'REJECTED'
)
BEGIN
    -- Update the leave record status with the decision
    UPDATE LEAVE_RECORD
    SET STATUS      = p_decision,
        APPROVED_BY = p_approved_by
    WHERE LEAVE_RECORD_ID = p_leave_record_id;

    -- Log the approval decision
    INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
    VALUES (
        'LEAVE_RECORD', 'UPDATE', p_leave_record_id,
        CONCAT('Leave ', p_decision, ' by Employee ID: ', p_approved_by)
    );

    SELECT CONCAT('Leave record #', p_leave_record_id,
                  ' has been ', p_decision) AS status;

END$$


-- ----------------------------------------------------------------
-- PROCEDURE 6: sp_record_performance_evaluation
-- What it does: Inserts a performance review and automatically
--   calculates the total score from the individual components.
--   Then updates the employee's rank accordingly.
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_record_performance_evaluation (
    IN p_employee_id              INT,
    IN p_supervisor_id            INT,
    IN p_evaluation_period        VARCHAR(50),
    IN p_pastor_score             DECIMAL(5,2),
    IN p_innovation_score         DECIMAL(5,2),
    IN p_teamwork_score           DECIMAL(5,2),
    IN p_christian_values_score   DECIMAL(5,2),
    IN p_service_delivery_score   DECIMAL(5,2),
    IN p_hra_form_completed       TINYINT(1)
)
BEGIN
    DECLARE v_total_score DECIMAL(5,2);
    DECLARE v_rank        VARCHAR(50);

    -- Calculate total score as the average of all 5 components
    -- Multiplied by 20 to convert to a score out of 100
    SET v_total_score = (
        p_pastor_score +
        p_innovation_score +
        p_teamwork_score +
        p_christian_values_score +
        p_service_delivery_score
    ) / 5;

    -- Map the score to a UCU performance rank using IF-ELSEIF logic
    IF v_total_score >= 90 THEN
        SET v_rank = 'Distinguished';       -- top performers
    ELSEIF v_total_score >= 75 THEN
        SET v_rank = 'Commendable';         -- above average
    ELSEIF v_total_score >= 60 THEN
        SET v_rank = 'Satisfactory';        -- meets expectations
    ELSEIF v_total_score >= 40 THEN
        SET v_rank = 'Needs Improvement';   -- below standard
    ELSE
        SET v_rank = 'Unsatisfactory';      -- serious underperformance
    END IF;

    -- Insert the evaluation record
    INSERT INTO PERFORMANCE_EVALUATIONS (
        EMPLOYEE_ID, SUPERVISOR_ID, EVALUATION_DATE, EVALUATION_PERIOD,
        DIRECTION_OF_PASTOR_SCORE, INNOVATION_SCORE, TEAMWORK_SCORE,
        CHRISTIAN_VALUES_SCORE, SERVICE_DELIVERY_SCORE,
        TOTAL_SCORE, HRA_FORM_COMPLETED
    )
    VALUES (
        p_employee_id, p_supervisor_id, CURDATE(), p_evaluation_period,
        p_pastor_score, p_innovation_score, p_teamwork_score,
        p_christian_values_score, p_service_delivery_score,
        v_total_score, p_hra_form_completed
    );

    -- Update the employee's rank in the EMPLOYEE table
    UPDATE EMPLOYEE
    SET EMPLOYEE_RANK = v_rank
    WHERE EMPLOYEE_ID = p_employee_id;

    -- Return the results
    SELECT p_employee_id  AS employee_id,
           v_total_score  AS total_score,
           v_rank         AS new_rank,
           'Evaluation recorded and rank updated' AS status;

END$$


-- ----------------------------------------------------------------
-- PROCEDURE 7: sp_record_training
-- What it does: Records a training/development activity for an
--   employee. If a bond is required, calculates the bond end date.
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_record_training (
    IN p_employee_id       INT,
    IN p_development_type  VARCHAR(100),
    IN p_institution       VARCHAR(100),
    IN p_start_date        DATE,
    IN p_end_date          DATE,
    IN p_bond_required     TINYINT(1),
    IN p_bonding_months    INT,
    IN p_approved_by       INT
)
BEGIN
    -- Insert training record
    INSERT INTO TRAINING_AND_DEVELOPMENT (
        EMPLOYEE_ID, DEVELOPMENT_TYPE, INSTITUTION,
        START_DATE, END_DATE, TODAY_DATE,
        BOND_REQUIRED, BONDING_PERIOD_MONTHS, APPROVED_BY
    )
    VALUES (
        p_employee_id, p_development_type, p_institution,
        p_start_date, p_end_date, CURDATE(),
        p_bond_required, p_bonding_months, p_approved_by
    );

    -- If bonding is required, show when the employee must stay until
    IF p_bond_required = 1 THEN
        SELECT
            LAST_INSERT_ID() AS training_id,
            p_institution    AS institution,
            p_end_date       AS training_ends,
            DATE_ADD(p_end_date, INTERVAL p_bonding_months MONTH) AS must_serve_until,
            'Training recorded — employee has a bond obligation' AS status;
    ELSE
        SELECT
            LAST_INSERT_ID() AS training_id,
            'Training recorded — no bond required' AS status;
    END IF;

END$$


-- ----------------------------------------------------------------
-- PROCEDURE 8: sp_process_separation
-- What it does: Handles an employee leaving UCU — resignation,
--   retirement, or dismissal. Updates their record and computes
--   severance if applicable.
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_process_separation (
    IN p_employee_id        INT,
    IN p_separation_type    VARCHAR(50),
    IN p_effective_date     DATE,
    IN p_notice_days        INT,
    IN p_processed_by       INT
)
BEGIN
    DECLARE v_salary           DECIMAL(12,2);
    DECLARE v_years_served     INT;
    DECLARE v_severance        DECIMAL(12,2) DEFAULT 0;

    -- Fetch the employee's salary
    SELECT f.SALARY INTO v_salary
    FROM FINANCIAL_DATA f
    JOIN EMPLOYEE e ON f.EMPLOYEE_ID = e.EMPLOYEE_ID
    WHERE e.EMPLOYEE_ID = p_employee_id;

    -- Calculate how many full years they worked at UCU
    SELECT TIMESTAMPDIFF(YEAR, e.HIRE_DATE, p_effective_date) INTO v_years_served
    FROM EMPLOYEE e
    WHERE e.EMPLOYEE_ID = p_employee_id;

    -- Severance = 1 month's salary per year served (for resignation/retirement)
    -- Dismissal gets NO severance
    IF p_separation_type IN ('RESIGNATION', 'RETIREMENT') THEN
        -- Monthly salary = annual / 12; multiply by years served
        SET v_severance = (v_salary / 12) * v_years_served;
    END IF;

    -- Insert the separation record
    INSERT INTO SEPARATION_RECORD (
        EMPLOYEE_ID, SEPARATION_TYPE, EFFECTIVE_DATE,
        NOTICE_PERIOD_DAYS, SEVERANCE_PAY_AMOUNT, PROCESSED_BY
    )
    VALUES (
        p_employee_id, p_separation_type, p_effective_date,
        p_notice_days, v_severance, p_processed_by
    );

    -- Log the separation
    INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
    VALUES (
        'SEPARATION_RECORD', 'INSERT', p_employee_id,
        CONCAT(p_separation_type, ' effective ', p_effective_date,
               '. Severance: UGX ', FORMAT(v_severance, 2))
    );

    SELECT p_employee_id     AS employee_id,
           p_separation_type AS separation_type,
           p_effective_date  AS effective_date,
           v_years_served    AS years_served,
           v_severance       AS severance_amount,
           'Separation processed' AS status;

END$$


-- ----------------------------------------------------------------
-- PROCEDURE 9: sp_issue_disciplinary_action
-- What it does: Creates a disciplinary record for an employee
--   misconduct case, categorised by severity.
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_issue_disciplinary_action (
    IN p_employee_id          INT,
    IN p_issued_by            INT,
    IN p_offence_description  TEXT,
    IN p_category             VARCHAR(50),   -- 'Minor', 'Major', 'Gross'
    IN p_sanction             VARCHAR(100)   -- 'Written Warning', 'Suspension', etc.
)
BEGIN
    -- Insert the disciplinary record
    INSERT INTO DISCIPLINARY_RECORD (
        EMPLOYEE_ID, ISSUED_BY, OFFENCE_DESCRIPTION,
        CATEGORY, SANCTION_ISSUED, DATE_ISSUED
    )
    VALUES (
        p_employee_id, p_issued_by, p_offence_description,
        p_category, p_sanction, CURDATE()
    );

    -- Log it for HR compliance records
    INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
    VALUES (
        'DISCIPLINARY_RECORD', 'INSERT', p_employee_id,
        CONCAT(p_category, ' offence — Sanction: ', p_sanction)
    );

    SELECT LAST_INSERT_ID()  AS disciplinary_id,
           p_category        AS category,
           p_sanction        AS sanction_issued,
           'Disciplinary action recorded' AS status;

END$$


-- ----------------------------------------------------------------
-- PROCEDURE 10: sp_complete_probation
-- What it does: Confirms or rejects an employee after their
--   6-month probation based on their evaluation score.
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_complete_probation (
    IN p_employee_id      INT,
    IN p_evaluation_score DECIMAL(5,2),
    IN p_pass_mark        DECIMAL(5,2)    -- typically 60.00
)
BEGIN
    DECLARE v_new_status VARCHAR(20);
    DECLARE v_probation_id INT;

    -- Get the probation record ID for this employee
    SELECT PROBATION_ID INTO v_probation_id
    FROM PROBATION
    WHERE EMPLOYEE_ID = p_employee_id AND PROBATION_STATUS = 'ONGOING'
    LIMIT 1;

    -- Determine pass or fail based on score vs pass mark
    IF p_evaluation_score >= p_pass_mark THEN
        SET v_new_status = 'PASSED';
    ELSE
        SET v_new_status = 'FAILED';
    END IF;

    -- Update probation record with result and score
    UPDATE PROBATION
    SET PROBATION_STATUS  = v_new_status,
        EVALUATION_SCORE  = p_evaluation_score
    WHERE PROBATION_ID    = v_probation_id;

    -- Log the outcome
    INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
    VALUES (
        'PROBATION', 'UPDATE', p_employee_id,
        CONCAT('Probation ', v_new_status,
               '. Score: ', p_evaluation_score, '/', p_pass_mark)
    );

    SELECT p_employee_id      AS employee_id,
           p_evaluation_score AS score,
           v_new_status       AS probation_result,
           IF(v_new_status = 'PASSED',
              'Employee confirmed — probation complete',
              'Employee did not pass — HR review required') AS message;

END$$


-- ----------------------------------------------------------------
-- PROCEDURE 11: sp_payroll_report
-- What it does: Generates full payroll for a given department
--   including NSSF deductions and net pay per employee.
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_payroll_report (
    IN p_department_id INT
)
BEGIN
    SELECT
        e.EMPLOYEE_ID,
        CONCAT(b.FIRST_NAME, ' ', b.LAST_NAME) AS full_name,
        pos.POSITION_TITLE,
        e.EMPLOYEE_RANK,
        f.SALARY                                AS gross_salary,
        -- Employee NSSF contribution is 5% of gross salary
        ROUND(f.SALARY * 0.05, 2)               AS nssf_employee_5pct,
        -- Employer NSSF contribution is 10% of gross salary
        ROUND(f.SALARY * 0.10, 2)               AS nssf_employer_10pct,
        -- Net pay = gross minus employee's own NSSF deduction
        ROUND(f.SALARY - (f.SALARY * 0.05), 2)  AS net_pay,
        f.BANK_NAME,
        f.ACCOUNT_NUMBER
    FROM EMPLOYEE e
    JOIN BIO_DATA       b   ON e.BIO_DATA_ID   = b.BIO_DATA_ID
    JOIN FINANCIAL_DATA f   ON e.FINANCIAL_ID  = f.FINANCIAL_ID
    LEFT JOIN POSITION  pos ON e.POSITION_ID   = pos.POSITION_ID
    WHERE e.DEPARTMENT_ID = p_department_id
    ORDER BY f.SALARY DESC;  -- highest earners first

END$$


-- ================================================================
-- SECTION 4: TRIGGERS
--
-- A trigger is SQL that fires AUTOMATICALLY when INSERT/UPDATE/DELETE
-- happens on a table. You never call a trigger manually — the
-- database engine fires it for you every time the event occurs.
-- ================================================================


-- ----------------------------------------------------------------
-- TRIGGER 1: trg_after_employee_insert
-- When: AFTER a new row is added to EMPLOYEE
-- Does: Auto-logs every new hire into AUDIT_LOG
-- ----------------------------------------------------------------
CREATE TRIGGER trg_after_employee_insert
AFTER INSERT ON EMPLOYEE     -- fires each time a new employee is added
FOR EACH ROW                 -- runs once per inserted row (not per statement)
BEGIN
    -- NEW.column = the value from the newly inserted row
    INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
    VALUES (
        'EMPLOYEE', 'INSERT', NEW.EMPLOYEE_ID,
        CONCAT('New hire registered. Hire date: ', NEW.HIRE_DATE,
               '. Dept ID: ', IFNULL(NEW.DEPARTMENT_ID, 'TBD'))
        -- IFNULL(x, y) returns y when x is NULL — prevents ugly 'NULL' in text
    );
END$$


-- ----------------------------------------------------------------
-- TRIGGER 2: trg_before_bio_insert
-- When: BEFORE inserting into BIO_DATA
-- Does: Blocks registration of anyone under 18 years old
-- ----------------------------------------------------------------
CREATE TRIGGER trg_before_bio_insert
BEFORE INSERT ON BIO_DATA
FOR EACH ROW
BEGIN
    -- TIMESTAMPDIFF(YEAR, birth, today) = age in completed years
    IF TIMESTAMPDIFF(YEAR, NEW.DOB, CURDATE()) < 18 THEN
        -- SIGNAL throws a custom error and stops the INSERT
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Employee must be at least 18 years old.';
    END IF;
END$$


-- ----------------------------------------------------------------
-- TRIGGER 3: trg_before_salary_update
-- When: BEFORE any update to FINANCIAL_DATA
-- Does: Enforces salary floor and blocks unauthorised cuts
-- ----------------------------------------------------------------
CREATE TRIGGER trg_before_salary_update
BEFORE UPDATE ON FINANCIAL_DATA
FOR EACH ROW
BEGIN
    -- OLD.SALARY = salary before the change
    -- NEW.SALARY = salary being set by the UPDATE

    -- Block if new salary is below the minimum threshold
    IF NEW.SALARY < 300000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Salary cannot be less than UGX 300,000.';
    END IF;

    -- Block salary reductions — these need a formal HR process
    IF NEW.SALARY < OLD.SALARY THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Salary reduction requires formal HR approval. Use the HR request form.';
    END IF;
END$$


-- ----------------------------------------------------------------
-- TRIGGER 4: trg_after_salary_update
-- When: AFTER a salary change is saved
-- Does: Logs old and new salary for compliance auditing
-- ----------------------------------------------------------------
CREATE TRIGGER trg_after_salary_update
AFTER UPDATE ON FINANCIAL_DATA
FOR EACH ROW
BEGIN
    -- Only log if the SALARY column actually changed value
    -- (prevents noise if other columns on the row were updated)
    IF OLD.SALARY <> NEW.SALARY THEN
        INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
        VALUES (
            'FINANCIAL_DATA', 'UPDATE', NEW.EMPLOYEE_ID,
            CONCAT('Salary changed: UGX ', FORMAT(OLD.SALARY, 2),
                   ' → UGX ', FORMAT(NEW.SALARY, 2))
        );
    END IF;
END$$


-- ----------------------------------------------------------------
-- TRIGGER 5: trg_after_employee_delete
-- When: AFTER an employee row is deleted
-- Does: Keeps a permanent trace of who was removed and when
-- ----------------------------------------------------------------
CREATE TRIGGER trg_after_employee_delete
AFTER DELETE ON EMPLOYEE
FOR EACH ROW
BEGIN
    -- OLD.column = the values from the row that was just deleted
    INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
    VALUES (
        'EMPLOYEE', 'DELETE', OLD.EMPLOYEE_ID,
        CONCAT('Employee record deleted. Hired: ', OLD.HIRE_DATE,
               '. Dept was: ', IFNULL(OLD.DEPARTMENT_ID, 'Unknown'))
    );
END$$


-- ----------------------------------------------------------------
-- TRIGGER 6: trg_after_evaluation_insert
-- When: AFTER a new performance evaluation is inserted
-- Does: Calculates total score and auto-updates employee rank
-- ----------------------------------------------------------------
CREATE TRIGGER trg_after_evaluation_insert
AFTER INSERT ON PERFORMANCE_EVALUATIONS
FOR EACH ROW
BEGIN
    DECLARE v_rank VARCHAR(50);

    -- Use CASE (like a switch statement) to determine rank from total score
    SET v_rank = CASE
        WHEN NEW.TOTAL_SCORE >= 90 THEN 'Distinguished'
        WHEN NEW.TOTAL_SCORE >= 75 THEN 'Commendable'
        WHEN NEW.TOTAL_SCORE >= 60 THEN 'Satisfactory'
        WHEN NEW.TOTAL_SCORE >= 40 THEN 'Needs Improvement'
        ELSE 'Unsatisfactory'
    END;

    -- Push the new rank into the EMPLOYEE table
    UPDATE EMPLOYEE
    SET EMPLOYEE_RANK = v_rank
    WHERE EMPLOYEE_ID = NEW.EMPLOYEE_ID;

    -- Log the rank change
    INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
    VALUES (
        'EMPLOYEE', 'UPDATE', NEW.EMPLOYEE_ID,
        CONCAT('Performance rank set to "', v_rank,
               '" (score: ', NEW.TOTAL_SCORE, ') for period: ', NEW.EVALUATION_PERIOD)
    );
END$$


-- ----------------------------------------------------------------
-- TRIGGER 7: trg_after_disciplinary_insert
-- When: AFTER a disciplinary record is created
-- Does: If offence is 'Gross', auto-flags for separation review
-- ----------------------------------------------------------------
CREATE TRIGGER trg_after_disciplinary_insert
AFTER INSERT ON DISCIPLINARY_RECORD
FOR EACH ROW
BEGIN
    -- A GROSS misconduct offence should trigger a separation review flag
    IF UPPER(NEW.CATEGORY) = 'GROSS' THEN
        INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
        VALUES (
            'DISCIPLINARY_RECORD', 'FLAG', NEW.EMPLOYEE_ID,
            CONCAT('⚠ GROSS MISCONDUCT flagged for Employee ID ',
                   NEW.EMPLOYEE_ID,
                   '. HR must review for possible dismissal. Sanction: ', NEW.SANCTION_ISSUED)
        );
    END IF;
END$$


-- ----------------------------------------------------------------
-- TRIGGER 8: trg_before_leave_insert
-- When: BEFORE a leave record is inserted
-- Does: Validates dates — end date must be after start date
-- ----------------------------------------------------------------
CREATE TRIGGER trg_before_leave_insert
BEFORE INSERT ON LEAVE_RECORD
FOR EACH ROW
BEGIN
    -- Reject if end date is before or equal to start date
    IF NEW.END_DATE <= NEW.START_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Leave end date must be after start date.';
    END IF;

    -- Auto-calculate days if not set by the caller
    -- DATEDIFF returns number of days between two dates
    IF NEW.DAYS_USED IS NULL OR NEW.DAYS_USED = 0 THEN
        SET NEW.DAYS_USED = DATEDIFF(NEW.END_DATE, NEW.START_DATE) + 1;
    END IF;
END$$


-- ----------------------------------------------------------------
-- TRIGGER 9: trg_after_probation_update
-- When: AFTER probation status is updated
-- Does: If probation FAILED, auto-logs a separation alert to HR
-- ----------------------------------------------------------------
CREATE TRIGGER trg_after_probation_update
AFTER UPDATE ON PROBATION
FOR EACH ROW
BEGIN
    -- Only act when status changed (not on every update)
    IF OLD.PROBATION_STATUS <> NEW.PROBATION_STATUS THEN

        -- Log the status change for all outcomes
        INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
        VALUES (
            'PROBATION', 'UPDATE', NEW.EMPLOYEE_ID,
            CONCAT('Probation status changed: ',
                   OLD.PROBATION_STATUS, ' → ', NEW.PROBATION_STATUS)
        );

        -- Extra alert if probation was failed — HR needs to act
        IF NEW.PROBATION_STATUS = 'FAILED' THEN
            INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
            VALUES (
                'PROBATION', 'FLAG', NEW.EMPLOYEE_ID,
                '⚠ PROBATION FAILED — HR action required: consider non-confirmation of appointment.'
            );
        END IF;

    END IF;
END$$


-- ----------------------------------------------------------------
-- TRIGGER 10: trg_after_separation_insert
-- When: AFTER a separation record is created
-- Does: Automatically marks the employee record for archiving
--   by clearing their active work email
-- ----------------------------------------------------------------
CREATE TRIGGER trg_after_separation_insert
AFTER INSERT ON SEPARATION_RECORD
FOR EACH ROW
BEGIN
    -- Deactivate the work email by adding a 'SEPARATED' prefix
    -- This preserves the old email for records but makes it clear
    -- the account should be deactivated in the system
    UPDATE EMPLOYEE
    SET WORK_EMAIL = CONCAT('SEPARATED_', EMPLOYEE_ID, '@ucu.ac.ug')
    WHERE EMPLOYEE_ID = NEW.EMPLOYEE_ID;

    -- Log the automatic deactivation
    INSERT INTO AUDIT_LOG (TABLE_NAME, ACTION_TYPE, RECORD_ID, DESCRIPTION)
    VALUES (
        'EMPLOYEE', 'UPDATE', NEW.EMPLOYEE_ID,
        CONCAT('Work email deactivated following ',
               NEW.SEPARATION_TYPE, ' effective ', NEW.EFFECTIVE_DATE)
    );
END$$


-- Restore the normal delimiter — everything after this is regular SQL
DELIMITER ;


-- ================================================================
-- SECTION 5: SAMPLE DATA & TEST CALLS
-- ================================================================

-- Create a division
INSERT INTO DIVISION (DIVISION_NAME) VALUES ('Academic Affairs');

-- Create a faculty
INSERT INTO FACULTY (DIVISION_ID, FACULTY_NAME, FACULTY_TYPE)
VALUES (1, 'Faculty of Science & Technology', 'Academic');

-- Create a department
INSERT INTO DEPARTMENT (FACULTY_ID, DEPARTMENT_NAME, OFFICE_LOCATION)
VALUES (1, 'Computer Science', 'Block C Room 104');

-- Create a position
INSERT INTO POSITION (POSITION_TITLE, DESCRIPTION, RANK, CONTRACT_DURATION_YEARS)
VALUES ('Lecturer', 'Teaches undergraduate and graduate courses', 'Grade 3', 2);

-- Register a new employee using the stored procedure
-- (This fires the trg_after_employee_insert and trg_before_bio_insert triggers automatically)
CALL sp_register_employee(
    'Sarah', 'Namutebi',        -- name
    '1988-07-22',               -- date of birth
    'F',                        -- gender
    'CM90012345678',            -- national ID
    's.namutebi@gmail.com',     -- personal email
    '0701234567',               -- phone
    '2024-02-01',               -- hire date
    1,                          -- department_id (Computer Science)
    1,                          -- position_id (Lecturer)
    NULL,                       -- supervisor (none yet)
    3500000.00,                 -- salary UGX
    'Centenary Bank',           -- bank
    '3210099887766',            -- account number
    'CF00112233'                -- NSSF number
);

-- View the full profile
CALL sp_get_full_employee_profile(1);

-- Record a performance evaluation
CALL sp_record_performance_evaluation(
    1,            -- employee_id
    1,            -- supervisor_id (self for now)
    'FY 2024',    -- period
    80,           -- pastor direction score
    75,           -- innovation score
    85,           -- teamwork score
    90,           -- christian values score
    78,           -- service delivery score
    1             -- HRA form completed (1 = Yes)
);

-- Apply for annual leave
CALL sp_apply_leave(1, 1, '2024-12-20', '2025-01-03', 'End of year family time');

-- Complete probation
CALL sp_complete_probation(1, 78.5, 60.0);

-- Issue a disciplinary action
CALL sp_issue_disciplinary_action(
    1,
    1,
    'Repeated late submission of student marks',
    'Minor',
    'Written Warning'
);

-- Process a separation
CALL sp_process_separation(1, 'RESIGNATION', '2025-06-30', 30, 1);

-- View the full audit trail of everything that happened
SELECT * FROM AUDIT_LOG ORDER BY CHANGED_AT DESC;
