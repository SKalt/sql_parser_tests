CREATE UNIQUE INDEX title_idx ON films (title) INCLUDE (director, rating);
