SELECT m.name AS mname, pname
FROM manufacturers m, LATERAL get_product_names(m.id) pname;
