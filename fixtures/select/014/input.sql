WITH t AS (
    SELECT random() as x FROM generate_series(1, 3)
  )
SELECT * FROM t
UNION ALL
SELECT * FROM t

--          x          
-- --------------------
--   0.534150459803641
--   0.520092216785997
--  0.0735620250925422
--   0.534150459803641
--   0.520092216785997
--  0.0735620250925422
