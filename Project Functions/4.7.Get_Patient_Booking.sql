CREATE OR REPLACE FUNCTION get_patient_booking(p_session_id UUID)
RETURNS TABLE (
    appointment_id VARCHAR,
    dentist_name VARCHAR,
    appointment_date DATE,
    appointment_time TIME,
    details VARCHAR,
    status VARCHAR
) AS $$
DECLARE
    session_user RECORD;
    session_user_id VARCHAR;
    session_is_admin BOOLEAN;
BEGIN
    -- Check session token
    SELECT user_id, is_admin INTO session_user_id, session_is_admin FROM get_session_user(p_session_id);
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid session token';
    END IF;

    -- Determine whether the user is an admin or a patient
    RETURN QUERY
    SELECT 
        a.appointment_id,
         (d.first_name || ' ' || COALESCE(d.middle_name, '') || ' ' || d.last_name)::VARCHAR AS dentist_name,
        a.appointment_date,
        a.time_slot,
        COALESCE(a.details, '')::VARCHAR,
        COALESCE(a.status, '')::VARCHAR
    FROM appointment_system a
    JOIN dentist d ON a.dentist_id = d.dentist_id
    WHERE session_is_admin IS TRUE OR a.patient_id = session_user_id;
END;
$$ LANGUAGE plpgsql;


-- Retrieve the patient's current booking as a regular user
SELECT * FROM get_patient_booking('37841c28-b3ec-4d2a-8e47-a1b2726f581f');

-- Retrieve all patients' bookings as an admin
SELECT * FROM get_patient_booking('e0d2c66e-6a7f-41c4-9a4c-4e87a787e4bb');