-- Create sequences for IDs
CREATE SEQUENCE IF NOT EXISTS patient_id_seq;
CREATE SEQUENCE IF NOT EXISTS appointment_id_seq;
-- Patient table (serves as users table)
CREATE TABLE Patient (
    patient_ID VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); 
-- New Medical History table
CREATE TABLE Medical_History (
    history_id VARCHAR PRIMARY KEY,
    patient_id VARCHAR NOT NULL,
    dentist_id VARCHAR NOT NULL,
    clinic_id VARCHAR NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    details VARCHAR,
    status VARCHAR,
    admin_id VARCHAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--OLD MEDICAL HISTORY TABLE
-- CREATE TABLE Medical_History (
--     medical_history_ID SERIAL PRIMARY KEY,
--     patient_ID VARCHAR(50),
--     dental_plan VARCHAR(100),
--     favorite_dentist VARCHAR(100),
--     treatment_history TEXT,
--     regist_date DATE,
--     FOREIGN KEY (patient_ID) REFERENCES Patient(patient_ID)
-- );

-- Contact Information table
CREATE TABLE Contact_Info (
    contact_ID SERIAL PRIMARY KEY,
    patient_ID VARCHAR(50),
    home_address TEXT,
    telephone VARCHAR(20),  -- Adding the telephone field
    FOREIGN KEY (patient_ID) REFERENCES Patient(patient_ID)
);
-- Admin table
CREATE TABLE Admin (
    admin_ID VARCHAR(50) PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dentist table
CREATE TABLE Dentist (
    dentist_ID VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    years_of_exp INTEGER NOT NULL
);

-- Dentist Expertise table (for multi-valued attribute)
CREATE TABLE Dentist_Expertise (
    dentist_ID VARCHAR(50),
    area_of_expertise VARCHAR(100),
    PRIMARY KEY (dentist_ID, area_of_expertise),
    FOREIGN KEY (dentist_ID) REFERENCES Dentist(dentist_ID)
);

-- Dental Clinic table
CREATE TABLE Dental_Clinic (
    clinic_ID VARCHAR(50) PRIMARY KEY,
    street VARCHAR(100),
    province VARCHAR(50),
    zip_code VARCHAR(20),
    city VARCHAR(50),
    state VARCHAR(50)
);

-- Facilities table
CREATE TABLE Facilities (
    facility_ID SERIAL PRIMARY KEY,
    clinic_ID VARCHAR(50),
    parking_spot INTEGER,
    seating_capacity INTEGER,
    reception_area BOOLEAN,
    dental_equipment TEXT,
    FOREIGN KEY (clinic_ID) REFERENCES Dental_Clinic(clinic_ID)
);
-- Appointment System table
CREATE TABLE Appointment_System (
    appointment_ID VARCHAR(50) PRIMARY KEY,
    patient_ID VARCHAR(50),
    dentist_ID VARCHAR(50),
    clinic_ID VARCHAR(50),
    admin_ID VARCHAR(50),
    appointment_date DATE NOT NULL,
    time_slot TIME NOT NULL,
    dentist_name VARCHAR(100),
    details TEXT,
    status VARCHAR(20) DEFAULT 'CONFIRMED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_ID) REFERENCES Patient(patient_ID),
    FOREIGN KEY (dentist_ID) REFERENCES Dentist(dentist_ID),
    FOREIGN KEY (clinic_ID) REFERENCES Dental_Clinic(clinic_ID),
    FOREIGN KEY (admin_ID) REFERENCES Admin(admin_ID),
    -- Ensure one booking per patient
    CONSTRAINT one_booking_per_patient UNIQUE (patient_ID)
);

-- Employment relationship table
CREATE TABLE Employment (
    dentist_ID VARCHAR(50),
    clinic_ID VARCHAR(50),
    PRIMARY KEY (dentist_ID, clinic_ID),
    FOREIGN KEY (dentist_ID) REFERENCES Dentist(dentist_ID),
    FOREIGN KEY (clinic_ID) REFERENCES Dental_Clinic(clinic_ID)
);
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE Sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), -- Unique session ID
    user_id VARCHAR NOT NULL,                              -- User ID associated with the session
    is_admin BOOLEAN DEFAULT FALSE,                        -- Admin status flag
    expires_at TIMESTAMPTZ NOT NULL,                       -- Expiration timestamp
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,      -- Creation timestamp
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP       -- Update timestamp
);
