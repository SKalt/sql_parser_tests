DELETE FROM films USING producers
  WHERE producer_id = producers.id AND producers.name = 'foo';
