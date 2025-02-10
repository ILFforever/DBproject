CREATE OR REPLACE FUNCTION finish_booking(
    p_session_id UUID,
    p_appointment_id VARCHAR
) RETURNS VARCHAR AS $$
DECLARE
    v_user_id VARCHAR;
    v_is_admin BOOLEAN;
    v_patient_id VARCHAR;
    v_dentist_id VARCHAR;
    v_clinic_id VARCHAR;
    v_appointment_date DATE;
    v_appointment_time TIME;
    v_details VARCHAR;
    v_status VARCHAR;
    v_admin_id VARCHAR;
BEGIN
    -- Check session token and get user details
    SELECT s.user_id, s.is_admin INTO v_user_id, v_is_admin
    FROM Sessions s
    WHERE s.session_id = p_session_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid session token';
    END IF;

    -- Get appointment details
    SELECT 
        ap.patient_id,
        ap.dentist_id,
        ap.clinic_id,
        ap.appointment_date,
        ap.time_slot,
        ap.details,
        ap.status,
        ap.admin_id
    INTO 
        v_patient_id,
        v_dentist_id,
        v_clinic_id,
        v_appointment_date,
        v_appointment_time,
        v_details,
        v_status,
        v_admin_id
    FROM Appointment_System ap
    WHERE ap.appointment_id = p_appointment_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid appointment ID';
    END IF;

    -- Check if the appointment is CONFIRMED
    IF v_status != 'CONFIRMED' THEN
        RAISE EXCEPTION 'Cannot close booking: Appointment is not CONFIRMED';
    END IF;

    -- Check if user is admin or patient in the booking
    IF v_is_admin IS NOT TRUE AND v_user_id != v_patient_id THEN
        RAISE EXCEPTION 'Unauthorized access: User is not authorized to finish the booking';
    END IF;

    -- Mark the booking as finished and insert into medical history
    INSERT INTO Medical_History (
        history_id,
        patient_id,
        dentist_id,
        clinic_id,
        appointment_date,
        appointment_time,
        details,
        status,
        admin_id
    ) VALUES (
        p_appointment_id,
        v_patient_id,
        v_dentist_id,
        v_clinic_id,
        v_appointment_date,
        v_appointment_time,
        v_details,
        'FINISHED',
        v_admin_id
    );

    -- Delete the original appointment
    DELETE FROM Appointment_System
    WHERE appointment_id = p_appointment_id;

    -- Return success message
    RETURN 'Appointment ' || p_appointment_id || ' closed';
END;
$$ LANGUAGE plpgsql;

-- Example: Finishing a booking
SELECT finish_booking(
    'e0d2c66e-6a7f-41c4-9a4c-4e87a787e4bb',  -- Session ID
    'APT-001'                                -- Appointment ID
);