# Salon Database - SQLite Schema

This directory contains the SQLite database schema and management scripts for the salon stylist appointment system.

## Database Structure

### Stylists Table
Stores stylist information and tracks their daily available appointment slots.

| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER | Primary key (auto-increment) |
| `name` | TEXT | Stylist's name (required) |
| `email` | TEXT | Stylist's email (unique) |
| `phone` | TEXT | Stylist's phone number |
| `available_slots` | INTEGER | Number of available slots (0-8, default: 8) |
| `last_reset_date` | DATE | Last date slots were reset |
| `created_at` | TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp |

### Appointments Table
Stores customer booking information.

| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER | Primary key (auto-increment) |
| `stylist_id` | INTEGER | Foreign key to stylists table |
| `customer_name` | TEXT | Customer's name (required) |
| `customer_email` | TEXT | Customer's email |
| `customer_phone` | TEXT | Customer's phone number |
| `appointment_date` | DATE | Date of appointment |
| `appointment_time` | TEXT | Time of appointment |
| `service_type` | TEXT | Type of service requested |
| `status` | TEXT | Status: 'confirmed', 'cancelled', 'completed' |
| `created_at` | TIMESTAMP | Booking creation timestamp |

## Key Features

### 1. Automatic Slot Management
- **Initial slots**: Each stylist starts with 8 available slots per day
- **Auto-decrement**: When an appointment is booked (status='confirmed'), available_slots decreases by 1
- **Auto-increment**: When an appointment is cancelled, available_slots increases by 1 (max 8)
- **Daily reset**: All stylists' available_slots reset to 8 at midnight

### 2. Database Triggers
The schema includes automatic triggers:
- `decrement_slots_on_booking`: Reduces slots when appointments are created
- `increment_slots_on_cancellation`: Restores slots when appointments are cancelled

## Setup Instructions

### 1. Install Dependencies
```bash
cd database
npm install
```

### 2. Initialize Database
```bash
npm run init
```

This will:
- Create the SQLite database file (`salon.db`)
- Create all tables with proper schema
- Insert sample stylist data
- Display the current stylists

### 3. Test the Database
You can manually test with SQLite CLI:
```bash
sqlite3 salon.db
```

Example queries:
```sql
-- View all stylists
SELECT * FROM stylists;

-- Book an appointment (this will auto-decrement available_slots)
INSERT INTO appointments (stylist_id, customer_name, appointment_date, appointment_time, service_type)
VALUES (1, 'John Doe', '2025-12-05', '10:00 AM', 'Haircut');

-- Check updated slots
SELECT name, available_slots FROM stylists WHERE id = 1;

-- Cancel an appointment (this will auto-increment available_slots)
UPDATE appointments SET status = 'cancelled' WHERE id = 1;
```

## Daily Reset Mechanism

### Option 1: Manual Reset
Run the reset script manually:
```bash
npm run reset-slots
```

### Option 2: Automated Reset with Cron (Linux/Mac)
Add to your crontab to run daily at midnight:
```bash
crontab -e
```

Add this line:
```
0 0 * * * cd /home/user/ACIT1620/database && /usr/bin/node reset-slots.js >> /tmp/slot-reset.log 2>&1
```

### Option 3: Automated Reset with Task Scheduler (Windows)
1. Open Task Scheduler
2. Create a new task
3. Set trigger: Daily at 12:00 AM
4. Set action: Run program
   - Program: `node`
   - Arguments: `C:\path\to\ACIT1620\database\reset-slots.js`

### Option 4: Node.js Scheduled Service
For a continuously running service, edit `reset-slots.js` and uncomment the scheduler section.

First install the scheduler:
```bash
npm install node-schedule
```

Then run as a service:
```bash
node reset-slots.js
```

This will keep running and execute the reset at midnight every day.

## Usage Example

### Booking Workflow
1. **Check availability**: Query `available_slots` for desired stylist
2. **Book appointment**: Insert into `appointments` table
3. **Automatic update**: Trigger automatically decrements `available_slots`
4. **Daily reset**: Slots reset to 8 at midnight via scheduled script

### Example Code (Node.js)
```javascript
const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./database/salon.db');

// Check availability
db.get('SELECT name, available_slots FROM stylists WHERE id = ?', [1], (err, row) => {
    if (row.available_slots > 0) {
        console.log(`${row.name} has ${row.available_slots} slots available`);

        // Book appointment
        db.run(`
            INSERT INTO appointments
            (stylist_id, customer_name, appointment_date, appointment_time, service_type)
            VALUES (?, ?, ?, ?, ?)
        `, [1, 'Jane Smith', '2025-12-05', '2:00 PM', 'Hair Coloring'], (err) => {
            if (!err) {
                console.log('Appointment booked! Slot automatically decremented.');
            }
        });
    } else {
        console.log('No slots available for this stylist today.');
    }
});
```

## File Structure
```
database/
├── schema.sql          # Database schema definition
├── init-db.js          # Database initialization script
├── reset-slots.js      # Daily reset script
├── package.json        # Node.js dependencies
├── salon.db            # SQLite database file (created after init)
└── README.md           # This file
```

## Maintenance

### View Current Status
```bash
sqlite3 salon.db "SELECT id, name, available_slots, last_reset_date FROM stylists;"
```

### Manual Slot Reset
```bash
sqlite3 salon.db "UPDATE stylists SET available_slots = 8, last_reset_date = date('now');"
```

### Backup Database
```bash
cp salon.db salon.db.backup
```

## Troubleshooting

### Slots not resetting
- Verify cron job is running: `crontab -l`
- Check reset script logs
- Manually run: `npm run reset-slots`

### Slots going below 0
- Check constraint is working: `PRAGMA table_info(stylists);`
- Verify triggers are active: `.schema appointments`

### Slots not decrementing on booking
- Verify appointment status is 'confirmed'
- Check that stylist_id exists in stylists table
- Examine triggers: `SELECT * FROM sqlite_master WHERE type='trigger';`

## Notes
- The database uses SQLite's built-in date/time functions
- All dates are stored in ISO 8601 format (YYYY-MM-DD)
- Triggers ensure data consistency automatically
- The `last_reset_date` field prevents multiple resets on the same day
