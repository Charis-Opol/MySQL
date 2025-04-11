CREATE DATABASE hospital_db;

USE hospital_db;

CREATE TABLE Patients(
    Patient_ID VARCHAR(8) PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Date_of_birth DATE NOT NULL,
    Gender CHAR(1),
    Phone VARCHAR(10),
    Email VARCHAR(25),
    CONSTRAINT chk_gender CHECK(Gender = 'F' OR Gender = 'M' OR Gender = 'O'),
    CONSTRAINT unq_phone UNIQUE(Phone),
    CONSTRAINT chk_email CHECK(Email LIKE '%@%.%')
);

ALTER TABLE  Patients
ADD CONSTRAINT chk_name_upper CHECK(Name = UPPER(Name))

CREATE TABLE Doctors(
    Doctor_ID VARCHAR(8) PRIMARY KEY,
    Doctor_Name VARCHAR(50),
    Specialization VARCHAR(20),
    Phone VARCHAR(10),
    Email VARCHAR(25),
    CONSTRAINT chk_phone_number CHECK(LENGTH(Phone) = 10) 
)

ALTER TABLE Doctors
ADD CONSTRAINT chk_name_lower CHECK(Doctor_Name = LOWER(Doctor_Name)),
ADD CONSTRAINT chk_hosptial_email CHECK(Email LIKE '%@hospital.%');

CREATE TABLE Appointments(
    AppointmentID VARCHAR(8) PRIMARY KEY,
    Patient_ID VARCHAR(8),
    Doctor_ID VARCHAR(8),
    Appointment_date DATE,
    Appointment_time TIME,
    Status VARCHAR(20),
    CONSTRAINT fhk_patient FOREIGN KEY (Patient_ID) REFERENCES Patients(Patient_ID),
    CONSTRAINT fhk_doctor FOREIGN KEY (Doctor_ID) REFERENCES Doctors(Doctor_ID),
    CONSTRAINT chk_status CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled'))
);

INSERT INTO Patients VALUES('P002', 'CHARTON SOB', '1999-05-21', 'M', '0753211343', 'cartonsob@gmail.com');
INSERT INTO Patients VALUES('P007', 'JUIEL TLOE', '1966-02-01', 'F', '0757211343', 'Jt@gmail.com');
INSERT INTO Patients VALUES('P012', 'BOB SUAT', '2000-04-23', 'M', '0753200343', 'bobs@gmail.com');

SELECT * FROM Patients;

INSERT INTO Doctors VALUES('D001', 'james bond', 'Orthopedics', '0753341343', 'jamesbond@hospital.com');
INSERT INTO Doctors VALUES('D002', 'john wick', 'Infective illness', '0756671343', 'johnwick@hospital.com');

SELECT * FROM Doctors;

ALTER TABLE Patients
ADD COLUMN Address VARCHAR(10);

UPDATE Patients
SET Address = 'Greece'
WHERE Patient_ID = 'P002';

UPDATE Patients
SET Address = 'Kampala'
WHERE Patient_ID = 'P007';

UPDATE patients
SET Address = 'Guleu'
WHERE Patient_ID = 'P012';

SELECT * FROM Patients;

ALTER TABLE doctors
RENAME TO Physicians;

SELECT * FROM physicians;

ALTER TABLE Appointments
ADD COLUMN Timestamp TIMESTAMP;

ALTER TABLE Appointments
DROP Timestamp;

INSERT INTO Appointments VALUES('A0045', 'P002', 'D001', '2024-10-6', '18:23:00', 'Completed');

SELECT * FROM appointments;

CREATE VIEW Doctors_data2 AS
SELECT Doctor_ID, Doctor_Name, Email, Specialization FROM physicians
WHERE Email IS NOT NULL;

SELECT * FROM doctors_data2;

SELECT COUNT(Patient_ID) AS Number_Of_Patients
FROM Patients;

SELECT p.name, a.Appointment_date
FROM Patients p 
JOIN Appointments a ON p.Patient_ID=a.Patient_ID;

CREATE VIEW View3 AS
SELECT d.Doctor_Name, a.Patient_ID
FROM physicians d
JOIN appointments a ON d.Doctor_ID =a.Doctor_ID;

SELECT * FROM view3;

