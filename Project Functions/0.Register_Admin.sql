CREATE SEQUENCE admin_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1
--RUN THIS SEPERATELY
CREATE OR REPLACE FUNCTION register_admin(
    p_email VARCHAR,
    p_password_hash VARCHAR,
    p_first_name VARCHAR,
    p_last_name VARCHAR
) RETURNS VARCHAR AS $$
DECLARE
    new_admin_id VARCHAR(50);
BEGIN
    new_admin_id := 'A-' || CAST(nextval('admin_id_seq') AS VARCHAR);

    INSERT INTO Admin (
        admin_ID,
        email,
        password_hash,
        first_name,
        last_name,
        created_at
    )
    VALUES (
        new_admin_id,
        p_email,
        p_password_hash,
        p_first_name,
        p_last_name,
        NOW()
    );

    RETURN new_admin_id;
END;
$$ LANGUAGE plpgsql;


-- Register a new admin
SELECT register_admin(
    'admin@example.com',
    'hashed_password',
    'John',
    'Doe'
);