-- Trigger to automatically decrease available_slots when an appointment is booked
CREATE TRIGGER IF NOT EXISTS decrease_slots_on_booking
AFTER INSERT ON Appointments
FOR EACH ROW
BEGIN
    UPDATE Stylist
    SET available_slots = available_slots - 1
    WHERE stylist_id = NEW.stylist_id;
END;

-- Trigger to automatically increase available_slots when an appointment is deleted
CREATE TRIGGER IF NOT EXISTS increase_slots_on_cancellation
AFTER DELETE ON Appointments
FOR EACH ROW
BEGIN
    UPDATE Stylist
    SET available_slots = available_slots + 1
    WHERE stylist_id = OLD.stylist_id;
END;
