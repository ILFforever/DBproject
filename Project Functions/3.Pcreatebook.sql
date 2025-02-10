--Update 10/2/25 by hammy
--update return and add details and doctor name to appointment table
--new input format only session id needed will find the user id from session table
CREATE OR REPLACE FUNCTION create_booking(
    p_session_id UUID,
    p_dentist_id VARCHAR,
    p_clinic_id VARCHAR,
    p_appointment_date DATE,
    p_appointment_time TIME,
    p_details TEXT
) RETURNS TABLE (
    appointment_id VARCHAR,
    patient_id VARCHAR,
    dentist_id VARCHAR,
    clinic_id VARCHAR,
    appointment_date DATE,
    appointment_time TIME,
    details VARCHAR
) AS $$
DECLARE
    new_appointment_id VARCHAR(50);
    v_user_id VARCHAR;
BEGIN
    -- Check session token and get user details
    SELECT s.user_id INTO v_user_id
    FROM Sessions s
    WHERE s.session_id = p_session_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid session token';
    END IF;
    
    -- Check if patient exists
    IF NOT EXISTS (SELECT 1 FROM Patient p WHERE p.patient_id = v_user_id) THEN
        RAISE EXCEPTION 'Patient ID % does not exist', v_user_id;
    END IF;

    -- Check if dentist exists
    IF NOT EXISTS (SELECT 1 FROM Dentist d WHERE d.dentist_id = p_dentist_id) THEN
        RAISE EXCEPTION 'Dentist ID % does not exist', p_dentist_id;
    END IF;

    -- Check if clinic exists
    IF NOT EXISTS (SELECT 1 FROM Dental_Clinic c WHERE c.clinic_id = p_clinic_id) THEN
        RAISE EXCEPTION 'Clinic ID % does not exist', p_clinic_id;
    END IF;
    
    -- Check if patient already has an active booking
    IF EXISTS (SELECT 1 FROM Appointment_System a WHERE a.patient_ID = v_user_id AND a.status IN ('PENDING', 'CONFIRMED')) THEN
        RAISE EXCEPTION 'Patient already has an active booking';
    END IF;
    
    new_appointment_id := 'APT-' || CAST(nextval('appointment_id_seq') AS VARCHAR);

    -- Insert new booking
    INSERT INTO Appointment_System (
        appointment_ID,
        patient_ID,
        dentist_ID,
        clinic_ID,
        appointment_date,
        time_slot,
        details,
        status
    )
    VALUES (
        new_appointment_id,
        v_user_id,
        p_dentist_id,
        p_clinic_id,
        p_appointment_date,
        p_appointment_time,
        p_details,
        'PENDING'
    );
    
    RETURN QUERY
    SELECT 
        new_appointment_id AS appointment_id,
        v_user_id AS patient_id,
        p_dentist_id AS dentist_id,
        p_clinic_id AS clinic_id,
        p_appointment_date AS appointment_date,
        p_appointment_time AS appointment_time,
        CAST(p_details AS VARCHAR) AS details;
END;
$$ LANGUAGE plpgsql;

-- -- Example 1: Creating a new booking with a valid session token
-- SELECT * FROM create_booking(
--     'e0d2c66e-6a7f-41c4-9a4c-4e87a787e4bb',
--     'D001',
--     'C001',
--     '2025-02-15',
--     '10:00',
--     'Routine Checkup'
-- );

-- -- Example 2: Creating another new booking with a valid session token
-- SELECT * FROM create_booking(
--     'e0d2c66e-6a7f-41c4-9a4c-4e87a787e4bb',
--     'D002',
--     'C002',
--     '2025-03-01',
--     '14:00',
--     'Routine Checkup'
-- );

-- -- Example 3: Attempting to create a booking with an invalid session token
-- SELECT * FROM create_booking(
--     'invalid-session-id',
--     'D003',
--     'C003',
--     '2025-04-01',
--     '09:00',
--     'Routine Checkup'
-- );

CREATE OR REPLACE FUNCTION get_doctors_details()
RETURNS TABLE (dentist_id VARCHAR, first_name VARCHAR, middle_name VARCHAR, last_name VARCHAR, speciality VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT d.dentist_id, d.first_name, d.middle_name, d.last_name, de.area_of_expertise AS speciality
    FROM Dentist d
    JOIN Dentist_Expertise de ON d.dentist_id = de.dentist_id;
END;
$$ LANGUAGE plpgsql;

--NOT USED
-- CREATE OR REPLACE FUNCTION show_doctors_and_create_booking(
--     p_session_id UUID,
--     p_patient_id VARCHAR,
--     p_clinic_id VARCHAR,
--     p_appointment_date DATE,
--     p_appointment_time TIME,
--     p_dentist_id VARCHAR
-- ) RETURNS VARCHAR AS $$
-- DECLARE
--     session_user RECORD;
-- BEGIN
--     -- Check session token
--     SELECT * INTO session_user FROM get_session_user(p_session_id);
--     IF NOT FOUND THEN
--         RAISE EXCEPTION 'Invalid session token';
--     END IF;

--     -- Validate the selected dentist ID
--     IF NOT EXISTS (SELECT 1 FROM Dentist WHERE dentist_id = p_dentist_id) THEN
--         RAISE EXCEPTION 'Invalid dentist ID %', p_dentist_id;
--     END IF;

--     -- Call the create_booking function with the selected doctor's details
--     RETURN create_booking(p_session_id, p_patient_id, p_dentist_id, p_clinic_id, p_appointment_date, p_appointment_time);
-- END;
-- $$ LANGUAGE plpgsql;

-- Example Usage:
-- First, retrieve and display the list of doctors:

-- SELECT * FROM get_doctors_details();
-- Then, once the user has made a selection (let's assume they selected 'D001'), use that selection to create the booking:

-- SELECT show_doctors_and_create_booking(
--     'e0d2c66e-6a7f-41c4-9a4c-4e87a787e4bb', -- Session ID
--     'P001',                                -- Patient ID
--     'C001',                                -- Clinic ID
--     '2025-02-15',                          -- Appointment Date
--     '10:00',                               -- Appointment Time
--     'D001'