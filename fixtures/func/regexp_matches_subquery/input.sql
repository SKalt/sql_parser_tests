SELECT col1, (SELECT regexp_matches(col2, '(bar)(beque)')) FROM tab;
