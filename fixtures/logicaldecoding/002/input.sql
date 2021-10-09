BEGIN;
INSERT INTO data(data) VALUES('5');
PREPARE TRANSACTION 'test_prepared1';

SELECT * FROM pg_logical_slot_get_changes('regression_slot', NULL, NULL);
--     lsn    | xid |                          data                           
-- -----------+-----+---------------------------------------------------------
--  0/1689DC0 | 529 | BEGIN 529
--  0/1689DC0 | 529 | table public.data: INSERT: id[integer]:3 data[text]:'5'
--  0/1689FC0 | 529 | PREPARE TRANSACTION 'test_prepared1', txid 529
-- (3 rows)

COMMIT PREPARED 'test_prepared1';
select * from pg_logical_slot_get_changes('regression_slot', NULL, NULL);
--     lsn    | xid |                    data                    
-- -----------+-----+--------------------------------------------
--  0/168A060 | 529 | COMMIT PREPARED 'test_prepared1', txid 529
-- (4 row)

-- you can also rollback a prepared transaction
BEGIN;
INSERT INTO data(data) VALUES('6');
PREPARE TRANSACTION 'test_prepared2';
-- select * from pg_logical_slot_get_changes('regression_slot', NULL, NULL);
--     lsn    | xid |                          data                           
-- -----------+-----+---------------------------------------------------------
--  0/168A180 | 530 | BEGIN 530
--  0/168A1E8 | 530 | table public.data: INSERT: id[integer]:4 data[text]:'6'
--  0/168A430 | 530 | PREPARE TRANSACTION 'test_prepared2', txid 530
-- (3 rows)

ROLLBACK PREPARED 'test_prepared2';
select * from pg_logical_slot_get_changes('regression_slot', NULL, NULL);
--     lsn    | xid |                     data                     
-- -----------+-----+----------------------------------------------
--  0/168A4B8 | 530 | ROLLBACK PREPARED 'test_prepared2', txid 530
-- (1 row)
