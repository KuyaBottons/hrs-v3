-- Fix module name mismatches between DB and PHP API files
-- Run in phpMyAdmin on geamh_hris database

USE `geamh_hris`;

-- PHP uses 'Employee Masterlist', DB has 'Employees'
UPDATE module_permissions SET module = 'Employee Masterlist' WHERE module = 'Employees';

-- PHP uses 'Audit History', DB has 'Audit Logs'
UPDATE module_permissions SET module = 'Audit History' WHERE module = 'Audit Logs';

-- PHP uses 'Schedule Database', DB has 'Schedules'
UPDATE module_permissions SET module = 'Schedule Database' WHERE module = 'Schedules';

-- Fix user with empty role (username: admin)
UPDATE users SET role = 'Admin' WHERE username = 'admin' AND (role = '' OR role IS NULL);

-- Verify
SELECT module, COUNT(*) as count FROM module_permissions GROUP BY module ORDER BY module;
SELECT id, username, name, role FROM users ORDER BY id;
