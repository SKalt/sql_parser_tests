SELECT m.* FROM some_table, LATERAL myfunc(x) AS m;
