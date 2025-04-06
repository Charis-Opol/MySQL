CREATE DATABASE Practice_work;
USE Practice_work;

CREATE TABLE Patient(
    PatientID VARCHAR(10) NOT NULL PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    Age INT NOT NULL,
    Gender VARCHAR(8),
    Contact VARCHAR(10),
    CONSTRAINT chk_contact CHECK (LENGTH(Contact) = 10),
    CONSTRAINT chk_Patientname CHECK (BINARY name = UPPER(name)),
    CONSTRAINT chk_age CHECK (Age > 3),
    CONSTRAINT chk_patientgender CHECK (Gender = 'Male' OR Gender = 'Female')
);

CREATE TABLE Doctor(
    DoctorID VARCHAR(10) NOT NULL PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    Specialization VARCHAR(15),
    Contact INT,
    CONSTRAINT chk_contact1 CHECK (LENGTH(Contact) = 10)
);

CREATE TABLE Appointment(
    AppointmentID VARCHAR(10) NOT NULL PRIMARY KEY,
    PatientID VARCHAR(10) NOT NULL,
    DoctorID VARCHAR(10) NOT NULL,
    Date DATE,
    Time TIME,
    CONSTRAINT fhk_patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT fhk_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);

CREATE TABLE Prescription(
    PrescriptionID VARCHAR(5) NOT NULL PRIMARY KEY,
    AppointmentID VARCHAR(10) NOT NULL,
    Medicine VARCHAR(20),
    Dosage VARCHAR(10),
    CONSTRAINT fhk_appointment FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);

ALTER TABLE Patient 
DROP CONSTRAINT chk_age;

ALTER TABLE Patient
ADD CONSTRAINT chk_age CHECK (Age > 3);


INSERT INTO Patient VALUES('P001','JOHN KINTU',35,'M','0700111111');
INSERT INTO Patient VALUES('P002','SARAH NAMBI',28,'F','0700222222');
INSERT INTO Patient VALUES('P003','PAUL OKELLO',42,'M','0700333333');

ALTER TABLE Doctor
MODIFY COLUMN Contact VARCHAR(10);

INSERT INTO Doctor VALUES('101','Alex Bukenya','BPharm', '0700444444');
INSERT INTO Doctor VALUES('102','Diana Musoke','BPharm', '0700555555');
INSERT INTO Doctor VALUES('103','Solomon Opio','DPharm', '0700666666');

INSERT INTO Appointment VALUES('101','Alex Bukenya','BPharm', 0700444444);
INSERT INTO Appointment VALUES('101','Alex Bukenya','BPharm', 0700444444);
INSERT INTO Appointment VALUES('101','Alex Bukenya','BPharm', 0700444444);

UPDATE activity
SET name = 'Jim Jones'
WHERE ActivityCode = Ao1


CREATE VIEW view1
AS SELECT * FROM Patient
WHERE Gender = 'M';