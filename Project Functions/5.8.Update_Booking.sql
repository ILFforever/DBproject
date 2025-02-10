CREATE OR REPLACE FUNCTION update_booking(
    p_session_id UUID,
    p_appointment_id VARCHAR,
    p_dentist_id VARCHAR,
    p_clinic_id VARCHAR,
    p_appointment_date DATE,
    p_appointment_time TIME
) RETURNS BOOLEAN AS $$
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

    -- Check if the session user is an admin
    IF session_is_admin IS TRUE THEN
        -- Admin can update any booking
        UPDATE Appointment_System
        SET dentist_ID = p_dentist_id,
            clinic_ID = p_clinic_id,
            appointment_date = p_appointment_date,
            time_slot = p_appointment_time,
            updated_at = CURRENT_TIMESTAMP
        WHERE appointment_ID = p_appointment_id;
    ELSE
        -- Non-admin can only update their own booking
        UPDATE Appointment_System
        SET dentist_ID = p_dentist_id,
            clinic_ID = p_clinic_id,
            appointment_date = p_appointment_date,
            time_slot = p_appointment_time,
            updated_at = CURRENT_TIMESTAMP
        WHERE appointment_ID = p_appointment_id AND patient_ID = session_user_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Unauthorized access. Users can only update their own bookings';
        END IF;
    END IF;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

SELECT update_booking(
    'e0d2c66e-6a7f-41c4-9a4c-4e87a787e4bb',  -- Session ID (Admin session)
    'APT-001',                               -- Appointment ID
    'D002',                                  -- New Dentist ID
    'C002',                                  -- New Clinic ID
    '2025-02-15',                            -- Appointment Date remains the same
    '10:00'                                  -- Appointment Time remains the same
);