CREATE PUBLICATION insert_only FOR TABLE mydata
    WITH (publish = 'insert');