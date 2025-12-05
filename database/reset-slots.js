/**
 * Daily Slot Reset Script
 * Resets available_slots to 8 for all stylists at midnight
 * This should be run as a cron job or scheduled task
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'salon.db');

function resetDailySlots() {
    const db = new sqlite3.Database(DB_PATH, (err) => {
        if (err) {
            console.error('Error opening database:', err.message);
            process.exit(1);
        }
    });

    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD format

    // Reset slots for stylists whose last_reset_date is not today
    const resetQuery = `
        UPDATE stylists
        SET available_slots = 8,
            last_reset_date = ?,
            updated_at = CURRENT_TIMESTAMP
        WHERE last_reset_date < ?
    `;

    db.run(resetQuery, [today, today], function(err) {
        if (err) {
            console.error('Error resetting slots:', err.message);
            process.exit(1);
        }

        console.log(`[${new Date().toISOString()}] Reset complete: ${this.changes} stylist(s) updated`);

        // Log current status
        db.all('SELECT id, name, available_slots, last_reset_date FROM stylists', [], (err, rows) => {
            if (err) {
                console.error('Error querying stylists:', err.message);
            } else {
                console.log('\nCurrent stylist availability:');
                console.table(rows);
            }
            db.close();
        });
    });
}

// Run the reset
resetDailySlots();

// If you want to run this continuously as a service:
// Uncomment the following to schedule it to run at midnight every day
/*
const schedule = require('node-schedule');

// Schedule for midnight (00:00)
const job = schedule.scheduleJob('0 0 * * *', () => {
    console.log('Running scheduled daily reset...');
    resetDailySlots();
});

console.log('Slot reset scheduler started. Will run daily at midnight.');
*/
