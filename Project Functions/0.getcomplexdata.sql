CREATE OR REPLACE FUNCTION get_all_patients()
RETURNS TABLE (
    patient_id VARCHAR,
    first_name VARCHAR,
    middle_name VARCHAR,
    last_name VARCHAR,
    phone_number VARCHAR,
    email VARCHAR,
    home_address TEXT,
    telephone VARCHAR,
    total_appointments INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.patient_id,
        p.first_name,
        p.middle_name,
        p.last_name,
        p.phone_number,
        p.email,
        ci.home_address,
        ci.telephone,
        COALESCE(CAST(COUNT(mh.appointment_date) AS INTEGER), 0) AS total_appointments
    FROM 
        Patient p
    LEFT JOIN 
        Contact_Info ci ON p.patient_id = ci.patient_id
    LEFT JOIN 
        Medical_History mh ON p.patient_id = mh.patient_id
    GROUP BY 
        p.patient_id, p.first_name, p.middle_name, p.last_name, p.phone_number, p.email, ci.home_address, ci.telephone
    ORDER BY 
        total_appointments DESC;
END;
$$ LANGUAGE plpgsql;

-- Example: Get all patients with their contact info and total appointments
SELECT * FROM get_all_patients();
