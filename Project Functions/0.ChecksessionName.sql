CREATE OR REPLACE FUNCTION get_session_user(p_session_id UUID)
RETURNS TABLE (user_id VARCHAR, is_admin BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT s.user_id, s.is_admin
    FROM Sessions s
    WHERE s.session_id = p_session_id AND s.expires_at > CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- return userId and isAdmin
--SELECT * FROM get_session_user('37841c28-b3ec-4d2a-8e47-a1b2726f581f');