CREATE VIEW comedies AS
    SELECT *
    FROM films
    WHERE kind = 'Comedy';
