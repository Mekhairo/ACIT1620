CREATE TABLE stylists (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    available_slots INTEGER DEFAULT 8 CHECK(available_slots >= 0),
    last_reset_date DATE DEFAULT CURRENT_DATE
);
