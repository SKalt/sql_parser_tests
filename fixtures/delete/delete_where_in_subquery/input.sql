DELETE FROM films
  WHERE producer_id IN (SELECT id FROM producers WHERE name = 'foo');
