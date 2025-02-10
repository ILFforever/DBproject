CREATE OR REPLACE FUNCTION get_patient_contact(
    p_user_id VARCHAR
) RETURNS TABLE (
    patient_id VARCHAR,
    home_address TEXT,
    telephone VARCHAR
) AS $$
BEGIN
    -- Check if the patient exists
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE Patient.patient_id = p_user_id) THEN
        RAISE EXCEPTION 'Invalid user ID: %', p_user_id;
    END IF;

    -- Return the patient contact information
    RETURN QUERY
    SELECT 
        Contact_Info.patient_id, 
        Contact_Info.home_address, 
        Contact_Info.telephone
    FROM 
        Contact_Info
    WHERE 
        Contact_Info.patient_id = p_user_id;
END;
$$ LANGUAGE plpgsql;


-- Example: Get patient contact information
-- SELECT * FROM get_patient_contact('P-001');
