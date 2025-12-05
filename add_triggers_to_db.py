import sqlite3

# Connect to the StyleWise.DB database
conn = sqlite3.connect('StyleWise.DB')
cursor = conn.cursor()

# Read and execute the trigger SQL
with open('add_trigger.sql', 'r') as f:
    sql_script = f.read()
    cursor.executescript(sql_script)

# Commit changes
conn.commit()

print("Triggers added successfully!")

# Verify triggers were created
cursor.execute("SELECT name FROM sqlite_master WHERE type='trigger';")
triggers = cursor.fetchall()

print("\nTriggers in database:")
for trigger in triggers:
    print(f"  - {trigger[0]}")

conn.close()
