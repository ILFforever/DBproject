--new command 10/2/25
--for admin to approve appointments 
CREATE OR REPLACE FUNCTION admin_approve_booking(
    p_session_id UUID,
    p_appointment_id VARCHAR
) RETURNS TABLE (
    appointment_id VARCHAR,
    patient_id VARCHAR,
    dentist_id VARCHAR,
    dentist_name VARCHAR,
    clinic_id VARCHAR,
    appointment_date DATE,
    appointment_time TIME,
    details VARCHAR,
    status VARCHAR,
    admin_id VARCHAR
) AS $$
DECLARE
    v_status VARCHAR;
    v_user_id VARCHAR;
    v_is_admin BOOLEAN;
BEGIN
    -- Check session token and get user details
    SELECT s.user_id, s.is_admin INTO v_user_id, v_is_admin
    FROM Sessions s
    WHERE s.session_id = p_session_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid session token';
    END IF;

    -- Check if the user is an admin
    IF v_is_admin IS NOT TRUE THEN
        RAISE EXCEPTION 'Unauthorized access: User is not an admin';
    END IF;

    -- Check if the appointment ID is valid
    SELECT ap.status INTO v_status
    FROM Appointment_System ap
    WHERE ap.appointment_id = p_appointment_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid appointment ID';
    END IF;

    -- Check if the appointment is marked as PENDING
    IF v_status != 'PENDING' THEN
        RAISE EXCEPTION 'Cannot approve booking: Appointment is not in PENDING status';
    END IF;

    -- Update the appointment status to CONFIRMED and set the admin_id
    UPDATE Appointment_System ap
    SET status = 'CONFIRMED', admin_id = v_user_id
    WHERE ap.appointment_id = p_appointment_id;

    -- Return the full booking information
    RETURN QUERY
    SELECT 
        ap.appointment_id,
        ap.patient_id,
        ap.dentist_id,
        CAST(d.first_name || ' ' || d.last_name AS VARCHAR) AS dentist_name,
        ap.clinic_id,
        ap.appointment_date,
        ap.time_slot AS appointment_time,
        CAST(ap.details AS VARCHAR),
        ap.status,
        ap.admin_id
    FROM Appointment_System ap
    JOIN Dentist d ON ap.dentist_id = d.dentist_id
    WHERE ap.appointment_id = p_appointment_id;
    
    RAISE NOTICE 'Appointment % has been approved and set to CONFIRMED', p_appointment_id;
END;
$$ LANGUAGE plpgsql;


-- Example: Approving an appointment and returning the full booking information
SELECT * FROM admin_approve_booking(
    'e0d2c66e-6a7f-41c4-9a4c-4e87a787e4bb',  -- Session ID
    'APT-1'                                -- Appointment ID
);
