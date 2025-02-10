-- Functions for the booking system *PASS*
CREATE OR REPLACE FUNCTION register_patient(
    p_email VARCHAR,
    p_password VARCHAR,
    p_first_name VARCHAR,
    p_middle_name VARCHAR,
    p_last_name VARCHAR,
    p_phone_number VARCHAR,
    p_telephone_number VARCHAR,
    p_home_address TEXT
) RETURNS VARCHAR AS $$
DECLARE
    new_patient_id VARCHAR(50);
BEGIN
    new_patient_id := 'P-' || CAST(nextval('patient_id_seq') AS VARCHAR);
    
    -- Insert into Patient table
    INSERT INTO Patient (
        patient_ID,
        email,
        password_hash,
        first_name,
        middle_name,
        last_name,
        phone_number
    )
    VALUES (
        new_patient_id,
        p_email,
        p_password,
        p_first_name,
        p_middle_name,
        p_last_name,
        p_phone_number
    );

    -- Insert into Contact_Info table
    INSERT INTO Contact_Info (
        patient_ID,
        home_address,
        telephone
    )
    VALUES (
        new_patient_id,
        p_home_address,
        p_telephone_number
    );
    
    RETURN new_patient_id;
END;
$$ LANGUAGE plpgsql;



SELECT register_patient(
  'john.doe@example.com',
  'hashed_password123',
  'John',
  'Jacob',
  'Doe',
  '555-1234',
  '098-765-4321',           -- Telephone Number
  '123 Main St, Anytown'    -- Home Address
);

SELECT register_patient(
    'patient@example.com',    -- Email
    'securepassword',         -- Password
    'John',                   -- First Name
    'A.',                     -- Middle Name
    'Doe',                    -- Last Name
    '123-456-7890',           -- Phone Number
    '098-765-4321',           -- Telephone Number
    '123 Main St, Anytown'    -- Home Address
);