WITH w AS (
    SELECT * FROM big_table
)
SELECT * FROM w WHERE key = 123;