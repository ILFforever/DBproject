--updated 10/2/25 by hammy 
--return as table
--raise not found
-- session 3 hrs

CREATE OR REPLACE FUNCTION patient_login(
    p_email VARCHAR,
    p_password_hash VARCHAR
) RETURNS TABLE (
    session_id UUID,
    user_id VARCHAR,
    user_name VARCHAR
) AS $$

DECLARE
    pid VARCHAR;
    user_name VARCHAR;
BEGIN
    -- Check if the patient exists and has provided correct credentials
    SELECT patient_id, (first_name || ' ' || last_name)::VARCHAR INTO pid, user_name
    FROM Patient
    WHERE email = p_email AND password_hash = p_password_hash;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid email or password';
    END IF;

    RETURN QUERY
    WITH patient_data AS (
        SELECT pid, user_name
    ), delete_old_session AS (
        DELETE FROM Sessions s
        WHERE s.user_id = pid
    ), new_session AS (
        INSERT INTO Sessions (session_id, user_id, expires_at)
        VALUES (uuid_generate_v4(), pid, CURRENT_TIMESTAMP + INTERVAL '3 hour')
        RETURNING Sessions.session_id, Sessions.user_id
    )
    SELECT ns.session_id, pd.pid AS user_id, pd.user_name
    FROM patient_data pd, new_session ns;
END;

$$ LANGUAGE plpgsql;


-- -- Successful login
-- SELECT * FROM patient_login('john.doe@example.com', 'hashed_password123');

-- -- Failed login (incorrect email)
-- SELECT * FROM patient_login('jane.smith@example.com', 'hashed_password123');

-- -- Failed login (incorrect password)
-- SELECT * FROM patient_login('john.doe@example.com', 'wrongpassword');