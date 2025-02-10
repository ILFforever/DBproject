CREATE OR REPLACE FUNCTION logout_user_by_id(p_user_id VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    session_token UUID;
BEGIN
    -- Find the session token for the given user ID
    SELECT session_id INTO session_token FROM Sessions WHERE user_id = p_user_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No active session found for user ID %', p_user_id;
    END IF;

    -- Delete the session token
    DELETE FROM Sessions WHERE session_id = session_token;

    -- Check if the deletion was successful
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;


SELECT logout_user_by_id('P-1');