SELECT * FROM activity
SHOW TABLES



INSERT INTO activity (ActivityCode, Name, Duration, Funder)
VALUES (
    'AO2',
    'Light Bulb dress',
    3,
    'Department of Visual Arts'
  );

SELECT * FROM activity

ALTER TABLE team_member
ADD CONSTRAINT chk_telno CHECK (LENGTH(Telno) = 10)

ALTER TABLE team_member
ADD CONSTRAINT chk_name CHECK (BINARY name = UPPER(name))


