UPDATE films SET kind = 'Dramatic' WHERE CURRENT OF c_films;