CREATE DATABASE MOH;

USE MOH;

CREATE TABLE Patients(
    Patient_ID VARCHAR(10) PRIMARY KEY,
    Patient_name VARCHAR(50),
    DateOfBirth DATE,
    Gender CHAR(1),
    Contact VARCHAR(10)
);

ALTER TABLE Patients
MODIFY DateOfBirth VARCHAR(4);

CREATE TABLE Doctors(
    Doctor_ID VARCHAR(10) PRIMARY KEY,
    Doctor_Name VARCHAR(50) NOT NULL,
    Phone VARCHAR(10)
);

CREATE TABLE Medication(
    Medication_ID VARCHAR(10),
    Medication_name VARCHAR(15),
    Doctor_ID VARCHAR(10),
    Patient_ID VARCHAR(10),
    Dosage VARCHAR(5),
    CONSTRAINT fhk_patient1 FOREIGN KEY(Patient_ID) REFERENCES Patients(Patient_ID),
    CONSTRAINT fhk_doctor1 FOREIGN KEY(Doctor_ID) REFERENCES Doctors(Doctor_ID)
);

CREATE TABLE Admissions(
    Admission_ID VARCHAR(10) PRIMARY KEY,
    Patient_ID VARCHAR(10),
    Ward VARCHAR(10) NOT NULL,
    Status_of_clearance VARCHAR(15),
    CONSTRAINT fhk FOREIGN KEY(Patient_ID) REFERENCES Patients(Patient_ID)
);

INSERT INTO Patients VALUES('P00245', 'Jonathan Agule', '2006', 'M', '0748912736');
INSERT INTO Patients VALUES('P01005', 'Angelina Mukika', '1996', 'F', '0739169036');

INSERT INTO Doctors VALUES('D002', 'Kevin Kagigo', '0723912796');
INSERT INTO Doctors VALUES('D003', 'Paulo Opio', '0763934296');

INSERT INTO Medication VALUES('M050034', 'Pandol', 'D002', 'P00245','3x2');
INSERT INTO Medication VALUES('M050034', 'Quinine', 'D003', 'P01005','2x2');

INSERT INTO Admissions VALUES('A50034', 'P01005', 'Albert4', 'Pending');
INSERT INTO Admissions VALUES('A50044', 'P00245', 'Winnie4', 'Completed');

ALTER TABLE Patients
ADD COLUMN Address VARCHAR(15);

UPDATE Patients
SET Address = 'Karamoja'
WHERE Patient_ID = 'P00245';

UPDATE Patients
SET Address = 'Ssembabule'
WHERE Patient_ID = 'P01005';
ALTER TABLE Patients
RENAME COLUMN Patient_name TO patientz_name;

SELECT * FROM Patients;
SELECT *FROM Doctors;
SELECT * FROM Medication;
SELECT * FROM admissions;


CREATE TABLE Student(
    REGNO VARCHAR(10) PRIMARY KEY,
    Program VARCHAR(5),
    Age INT,
    Gender CHAR(1),
    Email VARCHAR(20),
    Telno VARCHAR(10),
    Lname VARCHAR(25)
);

ALTER TABLE Student
ADD CONSTRAINT chk_program CHECK(Program = 'BSIT' OR Program = 'BSCS' OR Program = 'BSDS' OR Program = 'DIT');

ALTER TABLE student
ADD CONSTRAINT chk_age CHECK(Age > 18),
ADD CONSTRAINT chk_gender CHECK(Gender = 'F'OR Gender = 'M'),
ADD CONSTRAINT chk_email CHECK(Email LIKE '%@%'),
ADD CONSTRAINT chk_number CHECK(LENGTH(Telno)=10),
ADD CONSTRAINT chk_lname CHECK(Lname = UPPER(Lname));

DESCRIBE Student;