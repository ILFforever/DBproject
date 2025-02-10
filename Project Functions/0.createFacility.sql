--Function to Insert a New Facility
CREATE OR REPLACE FUNCTION create_facility(
    p_clinic_id VARCHAR,
    p_parking_spot INTEGER,
    p_seating_capacity INTEGER,
    p_reception_area BOOLEAN,
    p_dental_equipment TEXT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO Facilities (clinic_id, parking_spot, seating_capacity, reception_area, dental_equipment)
    VALUES (p_clinic_id, p_parking_spot, p_seating_capacity, p_reception_area, p_dental_equipment);
END;
$$ LANGUAGE plpgsql;

-- Inserting a New Facility:

-- SELECT create_facility(
--     'C001',
--     50,
--     100,
--     TRUE,
--     'Dental chairs, X-ray machines, sterilizers'
-- );