CREATE OR REPLACE FUNCTION delete_appointment(
    p_session_id UUID,
    p_appointment_id VARCHAR
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

    -- Check if the session user is an admin or deleting their own appointment
    IF session_is_admin IS TRUE THEN
        -- Admin can delete any appointment
        DELETE FROM Appointment_System WHERE appointment_ID = p_appointment_id;
    ELSE
        -- Non-admin can only delete their own appointment
        DELETE FROM Appointment_System WHERE appointment_ID = p_appointment_id AND patient_ID = session_user_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Unauthorized access. Users can only delete their own appointments';
        END IF;
    END IF;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

SELECT delete_appointment(
    'admin-session-id',    -- Session ID (Admin session)
    'APT-001'              -- Appointment ID
);