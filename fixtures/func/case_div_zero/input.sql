SELECT * from test WHERE CASE WHEN x <> 0 THEN y/x > 1.5 ELSE false END;
