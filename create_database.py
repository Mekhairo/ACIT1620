import sqlite3

# Connect to (or create) the StyleWise.DB database
conn = sqlite3.connect('StyleWise.DB')
cursor = conn.cursor()

# Read and execute the SQL schema
with open('create_stylewise_db.sql', 'r') as f:
    sql_script = f.read()
    cursor.executescript(sql_script)

# Commit changes and close connection
conn.commit()
conn.close()

print("StyleWise.DB created successfully!")
