CREATE TABLE IF NOT EXISTS users (
    userid TEXT PRIMARY KEY,
    usergroup TEXT
);

CREATE TABLE IF NOT EXISTS groupcards (
    usergroup TEXT,
    cardid INTEGER,
    cardcount INTEGER,
    PRIMARY KEY (usergroup, cardid)
);