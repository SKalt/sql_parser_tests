CREATE INDEX gin_idx ON documents_table USING GIN (locations) WITH (fastupdate = off);
