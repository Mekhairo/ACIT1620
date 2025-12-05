/**
 * Database Initialization Script
 * Sets up SQLite database with stylists and appointments tables
 */

const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');

const DB_PATH = path.join(__dirname, 'salon.db');
const SCHEMA_PATH = path.join(__dirname, 'schema.sql');

// Create database connection
const db = new sqlite3.Database(DB_PATH, (err) => {
    if (err) {
        console.error('Error opening database:', err.message);
        process.exit(1);
    }
    console.log('Connected to SQLite database');
});

// Read and execute schema
fs.readFile(SCHEMA_PATH, 'utf8', (err, schema) => {
    if (err) {
        console.error('Error reading schema file:', err.message);
        process.exit(1);
    }

    // Execute schema statements
    db.exec(schema, (err) => {
        if (err) {
            console.error('Error creating tables:', err.message);
            process.exit(1);
        }
        console.log('Database schema created successfully');

        // Insert sample stylists
        insertSampleData();
    });
});

function insertSampleData() {
    const stylists = [
        { name: 'Sarah Johnson', email: 'sarah@salon.com', phone: '555-0101' },
        { name: 'Mike Chen', email: 'mike@salon.com', phone: '555-0102' },
        { name: 'Emily Rodriguez', email: 'emily@salon.com', phone: '555-0103' }
    ];

    const stmt = db.prepare(`
        INSERT OR IGNORE INTO stylists (name, email, phone, available_slots)
        VALUES (?, ?, ?, 8)
    `);

    stylists.forEach(stylist => {
        stmt.run(stylist.name, stylist.email, stylist.phone, (err) => {
            if (err) {
                console.error('Error inserting stylist:', err.message);
            }
        });
    });

    stmt.finalize(() => {
        console.log('Sample stylists added');

        // Verify the data
        db.all('SELECT * FROM stylists', [], (err, rows) => {
            if (err) {
                console.error('Error querying stylists:', err.message);
            } else {
                console.log('\nCurrent stylists:');
                console.table(rows);
            }
            db.close();
        });
    });
}
