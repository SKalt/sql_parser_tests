ALTER INDEX distributors SET (fillfactor = 75);
REINDEX INDEX distributors;
