CREATE OR REPLACE FUNCTION delete_expired_sessions()
RETURNS VOID AS $$
BEGIN
    DELETE FROM Sessions WHERE expires_at <= CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;