-- StyleWise Database Schema

-- Clients table
CREATE TABLE IF NOT EXISTS Clients (
    client_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    emails TEXT,
    phone TEXT
);

-- Stylist table
CREATE TABLE IF NOT EXISTS Stylist (
    stylist_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    specialty TEXT,
    available_slots INTEGER DEFAULT 8
);

-- Appointments table
CREATE TABLE IF NOT EXISTS Appointments (
    appointment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_date TEXT NOT NULL,
    confirmed INTEGER DEFAULT 0,
    client_id INTEGER,
    stylist_id INTEGER,
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (stylist_id) REFERENCES Stylist(stylist_id)
);
