--PASS
CREATE OR REPLACE FUNCTION create_dentist(
    p_dentist_id VARCHAR,
    p_first_name VARCHAR,
    p_middle_name VARCHAR,
    p_last_name VARCHAR,
    p_years_of_exp INTEGER,
    p_expertise VARCHAR[]
)
RETURNS VOID AS $$
DECLARE
    i INT;
BEGIN
    -- Insert into Dentist table
    INSERT INTO Dentist (dentist_id, first_name, middle_name, last_name, years_of_exp)
    VALUES (p_dentist_id, p_first_name, p_middle_name, p_last_name, p_years_of_exp);

    -- Check if expertise array is not empty
    IF array_length(p_expertise, 1) IS NOT NULL THEN
        -- Insert into Dentist_Expertise table
        FOR i IN 1 .. array_length(p_expertise, 1)
        LOOP
            INSERT INTO Dentist_Expertise (dentist_id, area_of_expertise)
            VALUES (p_dentist_id, p_expertise[i]);
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- -- Example 1: Inserting a new dentist with multiple areas of expertise
-- SELECT create_dentist(
--     'D001',
--     'John',
--     'A',
--     'Doe',
--     10,
--     ARRAY['Orthodontics', 'Cosmetic Dentistry']
-- );

-- -- Example 2: Inserting another new dentist with a single area of expertise
-- SELECT create_dentist(
--     'D002',
--     'Jane',
--     NULL,
--     'Smith',
--     5,
--     ARRAY['Pediatric Dentistry']
-- );

-- -- Example 3: Inserting yet another new dentist with no specified expertise
-- SELECT create_dentist(
--     'D003',
--     'Emily',
--     'B',
--     'Johnson',
--     8,
--     ARRAY[]::VARCHAR[]
-- );