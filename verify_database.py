import sqlite3

# Connect to the StyleWise.DB database
conn = sqlite3.connect('StyleWise.DB')
cursor = conn.cursor()

# Get list of all tables
cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
tables = cursor.fetchall()

print("Tables in StyleWise.DB:")
for table in tables:
    print(f"  - {table[0]}")

# Get schema for each table
for table in tables:
    table_name = table[0]
    print(f"\n{table_name} schema:")
    cursor.execute(f"PRAGMA table_info({table_name});")
    columns = cursor.fetchall()
    for col in columns:
        print(f"  {col[1]} ({col[2]})")

conn.close()
