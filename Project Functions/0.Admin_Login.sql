--new change 10/2/25
--admin session 12 hrs

CREATE OR REPLACE FUNCTION admin_login(
    p_email VARCHAR,
    p_password_hash VARCHAR
) RETURNS TABLE (
    session_id UUID,
    admin_id VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR
) AS $$
DECLARE
    admin_data RECORD;
    new_session_id UUID;
BEGIN
    -- Authenticate admin
    SELECT a.admin_id, a.first_name, a.last_name INTO admin_data
    FROM Admin a
    WHERE a.email = p_email AND a.password_hash = p_password_hash;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid email or password';
    END IF;

    -- Delete old session if any
    DELETE FROM Sessions WHERE user_id = admin_data.admin_id;

    -- Create new admin session
    new_session_id := uuid_generate_v4();
    INSERT INTO Sessions (session_id, user_id, is_admin, expires_at)
    VALUES (new_session_id, admin_data.admin_id, TRUE, CURRENT_TIMESTAMP + INTERVAL '12 hour');

    RETURN QUERY SELECT new_session_id, admin_data.admin_id, admin_data.first_name, admin_data.last_name;
END;
$$ LANGUAGE plpgsql;

-- Log in the admin and create a new session
SELECT * FROM admin_login('admin@example.com','hashed_password');