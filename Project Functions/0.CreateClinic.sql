--PASS
CREATE OR REPLACE FUNCTION create_dental_clinic(
    p_clinic_id VARCHAR,
    p_street VARCHAR,
    p_province VARCHAR,
    p_zip_code VARCHAR,
    p_city VARCHAR,
    p_state VARCHAR
) RETURNS VOID AS $$
BEGIN
    INSERT INTO Dental_Clinic (clinic_id, street, province, zip_code, city, state)
    VALUES (p_clinic_id, p_street, p_province, p_zip_code, p_city, p_state);
END;
$$ LANGUAGE plpgsql;

-- Example Usages:
-- Inserting a New Dental Clinic:

-- SELECT create_dental_clinic(
--     'C001',
--     '123 Main St',
--     'Bangkok',
--     '10100',
--     'Bangkok',
--     'Bangkok'
-- );
