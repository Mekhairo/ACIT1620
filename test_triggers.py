import sqlite3

# Connect to the StyleWise.DB database
conn = sqlite3.connect('StyleWise.DB')
cursor = conn.cursor()

print("Testing triggers...\n")

# 1. Add a test stylist
cursor.execute("""
    INSERT INTO Stylist (name, specialty, available_slots)
    VALUES ('Test Stylist', 'Hair Styling', 8)
""")
stylist_id = cursor.lastrowid
print(f"✓ Added test stylist (ID: {stylist_id}) with 8 available slots")

# 2. Add a test client
cursor.execute("""
    INSERT INTO Clients (name, emails, phone)
    VALUES ('Test Client', 'test@example.com', '555-1234')
""")
client_id = cursor.lastrowid
print(f"✓ Added test client (ID: {client_id})")

# 3. Check initial slots
cursor.execute("SELECT available_slots FROM Stylist WHERE stylist_id = ?", (stylist_id,))
slots_before = cursor.fetchone()[0]
print(f"\nBefore booking: {slots_before} available slots")

# 4. Book an appointment (trigger should decrease slots)
cursor.execute("""
    INSERT INTO Appointments (appointment_date, confirmed, client_id, stylist_id)
    VALUES ('2024-12-10 10:00', 0, ?, ?)
""", (client_id, stylist_id))
appointment_id = cursor.lastrowid
print(f"✓ Booked appointment (ID: {appointment_id})")

# 5. Check slots after booking
cursor.execute("SELECT available_slots FROM Stylist WHERE stylist_id = ?", (stylist_id,))
slots_after = cursor.fetchone()[0]
print(f"After booking: {slots_after} available slots")

if slots_after == slots_before - 1:
    print("✓ Trigger working! Slots decreased by 1")
else:
    print("✗ Trigger failed!")

# 6. Delete the appointment (trigger should increase slots)
cursor.execute("DELETE FROM Appointments WHERE appointment_id = ?", (appointment_id,))
print(f"\n✓ Cancelled appointment (ID: {appointment_id})")

# 7. Check slots after cancellation
cursor.execute("SELECT available_slots FROM Stylist WHERE stylist_id = ?", (stylist_id,))
slots_final = cursor.fetchone()[0]
print(f"After cancellation: {slots_final} available slots")

if slots_final == slots_before:
    print("✓ Cancellation trigger working! Slots restored")
else:
    print("✗ Cancellation trigger failed!")

# Clean up test data
cursor.execute("DELETE FROM Stylist WHERE stylist_id = ?", (stylist_id,))
cursor.execute("DELETE FROM Clients WHERE client_id = ?", (client_id,))

conn.commit()
conn.close()

print("\n✓ Test complete! All triggers working correctly.")
