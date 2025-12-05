-- SQLite Database Schema
-- Created: 2025-12-05

-- Stylists Table
-- Stores stylist information and their daily available appointment slots
CREATE TABLE IF NOT EXISTS stylists (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    available_slots INTEGER DEFAULT 8 NOT NULL CHECK(available_slots >= 0 AND available_slots <= 8),
    last_reset_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Appointments Table
-- Stores booking information
CREATE TABLE IF NOT EXISTS appointments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    stylist_id INTEGER NOT NULL,
    customer_name TEXT NOT NULL,
    customer_email TEXT,
    customer_phone TEXT,
    appointment_date DATE NOT NULL,
    appointment_time TEXT NOT NULL,
    service_type TEXT,
    status TEXT DEFAULT 'confirmed' CHECK(status IN ('confirmed', 'cancelled', 'completed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stylist_id) REFERENCES stylists(id) ON DELETE CASCADE
);

-- Trigger to decrement available_slots when an appointment is booked
CREATE TRIGGER IF NOT EXISTS decrement_slots_on_booking
AFTER INSERT ON appointments
WHEN NEW.status = 'confirmed'
BEGIN
    UPDATE stylists
    SET available_slots = available_slots - 1,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.stylist_id
    AND available_slots > 0;
END;

-- Trigger to increment available_slots when an appointment is cancelled
CREATE TRIGGER IF NOT EXISTS increment_slots_on_cancellation
AFTER UPDATE ON appointments
WHEN OLD.status = 'confirmed' AND NEW.status = 'cancelled'
BEGIN
    UPDATE stylists
    SET available_slots = CASE
        WHEN available_slots < 8 THEN available_slots + 1
        ELSE 8
    END,
    updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.stylist_id;
END;

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_appointments_stylist_date
ON appointments(stylist_id, appointment_date);

CREATE INDEX IF NOT EXISTS idx_stylists_reset_date
ON stylists(last_reset_date);
