CREATE POLICY user_policy ON users
    USING (user_name = current_user);