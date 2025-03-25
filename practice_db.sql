CREATE DATABASE Practice_work;
USE Practice_work;

CREATE TABLE Patient(
    PatientID VARCHAR(10) NOT NULL PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    Age INT NOT NULL,
    Gender CHAR(1),
    Contact VARCHAR(10),
    CONSTRAINT chk_contact CHECK (LENGTH(Contact) = 10),
    CONSTRAINT chk_name CHECK (BINARY name = UPPER(name)),
    CONSTRAINT chk_age CHECK (Age < 3),
    CONSTRAINT chk_gender CHECK (Gender = 'M' OR Gender = 'F')
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


UPDATE activity
SET name = 'Jim Jones'
WHERE ActivityCode = Ao1


CREATE VIEW view1