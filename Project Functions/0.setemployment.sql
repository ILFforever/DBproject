CREATE OR REPLACE FUNCTION add_employment(
    dentist_id_input VARCHAR,
    clinic_id_input VARCHAR
) RETURNS VOID AS $$
BEGIN
    -- Check if the dentist ID exists in the Dentist table
    IF NOT EXISTS (SELECT 1 FROM Dentist WHERE dentist_id = dentist_id_input) THEN
        RAISE EXCEPTION 'Invalid dentist ID: %', dentist_id_input;
    END IF;

    -- Check if the clinic ID exists in the Clinic table
    IF NOT EXISTS (SELECT 1 FROM Dental_Clinic WHERE clinic_id = clinic_id_input) THEN
        RAISE EXCEPTION 'Invalid clinic ID: %', clinic_id_input;
    END IF;

    -- Insert the dentist ID and clinic ID into the employment table
    INSERT INTO employment (dentist_id, clinic_id)
    VALUES (dentist_id_input, clinic_id_input);
END;
$$ LANGUAGE plpgsql;

-- Example: Adding a dentist to a clinic
SELECT add_employment(
    'D001',  -- Dentist ID
    'C001'   -- Clinic ID
);
