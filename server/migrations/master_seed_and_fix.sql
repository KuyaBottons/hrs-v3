-- ============================================================
--  GEAMH HRIS — Master Seed & Migration Fix
--  Run this in phpMyAdmin > geamh_hris > SQL tab
--  Safe to run multiple times (uses INSERT IGNORE / IF NOT EXISTS)
-- ============================================================

USE `geamh_hris`;

-- ============================================================
-- 1. FIX USERS TABLE — add missing columns
-- ============================================================
ALTER TABLE `users`
  MODIFY COLUMN `role` ENUM('Super Admin','Admin','DIOS','Section Admin','IT') NOT NULL DEFAULT 'Admin',
  ADD COLUMN IF NOT EXISTS `biometrics_number` VARCHAR(4) NULL COMMENT '1-4 digit biometrics login number' AFTER `username`,
  ADD COLUMN IF NOT EXISTS `position` VARCHAR(150) NULL AFTER `department`;

-- Add unique index on biometrics_number if not exists
SET @idx_exists = (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'users'
    AND index_name = 'idx_biometrics_number'
);
SET @sql = IF(@idx_exists = 0,
  'ALTER TABLE users ADD UNIQUE INDEX idx_biometrics_number (biometrics_number)',
  'SELECT "biometrics index already exists"'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Seed default DIOS account (password = SHA2('1234', 256) — biometrics 1234)
INSERT IGNORE INTO `users` (`id`, `username`, `biometrics_number`, `password`, `name`, `role`, `department`, `position`) VALUES
(1, 'dios',       '1234', SHA2('1234', 256), 'DIOS Administrator', 'DIOS',        'Information Technology', 'System Administrator'),
(2, 'superadmin', '1111', SHA2('1111', 256), 'Super Admin',        'Super Admin', 'Human Resources',        'HR Director'),
(3, 'admin',      '2222', SHA2('2222', 256), 'HR Admin',           'Admin',       'Human Resources',        'HR Officer');

-- ============================================================
-- 2. FIX EMPLOYEES TABLE — add missing columns
-- ============================================================
ALTER TABLE `employees`
  ADD COLUMN IF NOT EXISTS `hospital_group` ENUM('GEAMH','KPFP','') DEFAULT '' AFTER `employee_no`,
  ADD COLUMN IF NOT EXISTS `prc_license_number` VARCHAR(50) NULL AFTER `pi_number`,
  ADD COLUMN IF NOT EXISTS `prc_expiry_date` DATE NULL AFTER `prc_license_number`;

-- ============================================================
-- 3. DEPARTMENTS TABLE — ensure all departments exist
-- ============================================================
CREATE TABLE IF NOT EXISTS `departments` (
  `id`          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(100)    NOT NULL UNIQUE,
  `code`        VARCHAR(20)     DEFAULT NULL,
  `description` VARCHAR(255)    DEFAULT NULL,
  `active`      TINYINT(1)      NOT NULL DEFAULT 1,
  `created_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_dept_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `departments` (`name`, `code`, `description`) VALUES
-- GEAMH departments
('GEAMH-Nursing',                  'GE-NUR', 'GEAMH Nursing Services'),
('GEAMH-Laboratory',               'GE-LAB', 'GEAMH Clinical Laboratory'),
('GEAMH-Pharmacy',                 'GE-PHA', 'GEAMH Pharmacy'),
('GEAMH-Radiology',                'GE-RAD', 'GEAMH Radiology'),
('GEAMH-Rehabilitation',           'GE-RHB', 'GEAMH Rehabilitation Medicine'),
('GEAMH-Social Work',              'GE-SWD', 'GEAMH Social Work'),
('GEAMH-Medical Arts Building',    'GE-MAB', 'GEAMH Medical Arts Building'),
('GEAMH-Dialysis Extension Clinic','GE-DEC', 'GEAMH Dialysis Extension Clinic'),
('GEAMH-Maintenance',              'GE-MNT', 'GEAMH Maintenance'),
-- KP departments
('KP-Nursing',                     'KP-NUR', 'KPFP Nursing Services'),
('KP-Laboratory',                  'KP-LAB', 'KPFP Clinical Laboratory'),
('KP-Pharmacy',                    'KP-PHA', 'KPFP Pharmacy'),
('KP-Radiology',                   'KP-RAD', 'KPFP Radiology'),
('KP-Rehabilitation',              'KP-RHB', 'KPFP Rehabilitation Medicine'),
('KP-Social Work',                 'KP-SWD', 'KPFP Social Work'),
('KP-Medical Arts Building',       'KP-MAB', 'KPFP Medical Arts Building'),
('KP-Dialysis Extension Clinic',   'KP-DEC', 'KPFP Dialysis Extension Clinic'),
('KP-Maintenance',                 'KP-MNT', 'KPFP Maintenance'),
-- Shared / Admin
('Human Resources',                'HRD',    'Human Resources Department'),
('Information Technology',         'ITD',    'Information Technology'),
('Administrative',                 'ADM',    'Administrative Department'),
('Finance',                        'FIN',    'Finance and Accounting'),
('Security',                       'SEC',    'Security Department'),
('Dietary',                        'DIT',    'Dietary and Nutrition'),
('Medical Records',                'MRD',    'Medical Records'),
('Benefits Section',               'BEN',    'Benefits Section'),
('IM Doctors',                     'IMD',    'Internal Medicine Doctors'),
('OB Doctors',                     'OBD',    'OB-Gynecology Doctors'),
('Anesthesiology',                 'ANE',    'Anesthesiology Department'),
('Pediatrics',                     'PED',    'Pediatrics Department'),
('Emergency Room',                 'ER',     'Emergency Room Department'),
('ECG Department',                 'ECG',    'ECG Department'),
('Billing Department',             'BIL',    'Billing Department'),
('Linen Department',               'LIN',    'Linen Department'),
('Hemodialysis',                   'HEM',    'Hemodialysis Department'),
('Newborn Hearing Screening',      'NHS',    'Newborn Hearing Screening'),
('Admitting',                      'ADT',    'Admitting Department'),
('Transport',                      'TRN',    'Transport Department'),
('SHAO',                           'SHA',    'SHAO'),
('ICD-10 Coder',                   'ICD',    'ICD-10 Coding'),
('KP-Extension Clinic',            'KP-EXT', 'KP Extension Clinic');

-- ============================================================
-- 4. PRC LICENSES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `prc_licenses` (
  `id`          INT AUTO_INCREMENT PRIMARY KEY,
  `employee_id` INT(10) UNSIGNED NOT NULL,
  `license_number` VARCHAR(100) NOT NULL,
  `expiry_date` DATE NOT NULL,
  `remarks`     TEXT,
  `created_at`  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`employee_id`) REFERENCES `employees`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `uq_emp_license` (`employee_id`, `license_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX IF NOT EXISTS idx_prc_employee_id ON prc_licenses(employee_id);
CREATE INDEX IF NOT EXISTS idx_prc_expiry_date ON prc_licenses(expiry_date);

-- ============================================================
-- 5. AI SCANNED DOCS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `ai_scanned_docs` (
  `id`             INT(11) NOT NULL AUTO_INCREMENT,
  `file_name`      VARCHAR(255) NOT NULL,
  `file_path`      VARCHAR(500) DEFAULT NULL,
  `doc_type`       VARCHAR(100) DEFAULT 'Unknown',
  `file_size`      VARCHAR(50)  DEFAULT NULL,
  `confidence`     INT(11)      DEFAULT 0,
  `extracted_data` LONGTEXT     DEFAULT NULL,
  `raw_text`       LONGTEXT     DEFAULT NULL,
  `status`         VARCHAR(50)  DEFAULT 'Pending',
  `uploaded_by`    INT(11)      DEFAULT NULL,
  `created_at`     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_doc_type`    (`doc_type`),
  KEY `idx_status`      (`status`),
  KEY `idx_uploaded_by` (`uploaded_by`),
  KEY `idx_created_at`  (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. PASSWORD RESET REQUESTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `password_reset_requests` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`      INT UNSIGNED NOT NULL,
  `username`     VARCHAR(50)  NOT NULL,
  `user_name`    VARCHAR(100) NOT NULL,
  `status`       ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `requested_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` DATETIME     DEFAULT NULL,
  `processed_by` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_prr_status` (`status`),
  KEY `idx_prr_user`   (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 7. SHIFT LEGENDS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `shift_legends` (
  `id`             INT PRIMARY KEY AUTO_INCREMENT,
  `code`           VARCHAR(10)  NOT NULL,
  `department`     VARCHAR(100) DEFAULT NULL,
  `time_range`     VARCHAR(50)  NOT NULL,
  `color_primary`  VARCHAR(7)   NOT NULL,
  `color_secondary`VARCHAR(7)   DEFAULT NULL,
  `display_order`  INT          DEFAULT 0,
  `active`         BOOLEAN      DEFAULT TRUE,
  `created_at`     DATETIME     DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_code_dept` (`code`, `department`),
  INDEX `idx_department` (`department`),
  INDEX `idx_active`     (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `shift_legends` (`code`, `department`, `time_range`, `color_primary`, `color_secondary`, `display_order`, `active`) VALUES
('85',  NULL,      '8:00 AM - 5:00 PM',   '#000000', NULL,      1, TRUE),
('OFF', NULL,      'Off Duty',             '#F44336', NULL,      2, TRUE),
('H',   NULL,      'Holiday',              '#FF9800', NULL,      3, TRUE),
('62',  'Nursing', '6:00 AM - 2:00 PM',   '#2196F3', NULL,      1, TRUE),
('210', 'Nursing', '2:00 PM - 10:00 PM',  '#4CAF50', NULL,      2, TRUE),
('106', 'Nursing', '10:00 PM - 6:00 AM',  '#F44336', NULL,      3, TRUE),
('610', 'Nursing', '6:00 AM - 10:00 PM',  '#2196F3', '#4CAF50', 4, TRUE),
('26',  'Nursing', '2:00 PM - 6:00 AM',   '#4CAF50', '#F44336', 5, TRUE),
('85',  'Nursing', '8:00 AM - 5:00 PM',   '#000000', NULL,      6, TRUE),
('OFF', 'Nursing', 'Off Duty',             '#F44336', NULL,      7, TRUE)
ON DUPLICATE KEY UPDATE
  `time_range`     = VALUES(`time_range`),
  `color_primary`  = VALUES(`color_primary`),
  `color_secondary`= VALUES(`color_secondary`),
  `display_order`  = VALUES(`display_order`),
  `active`         = VALUES(`active`);

-- ============================================================
-- 8. SCHEDULE TRANSMITTALS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `schedule_transmittals` (
  `id`             INT PRIMARY KEY AUTO_INCREMENT,
  `department`     VARCHAR(100) NOT NULL,
  `period_start`   DATE         NOT NULL,
  `period_end`     DATE         NOT NULL,
  `page_number`    INT          DEFAULT 1,
  `staff_count`    INT          DEFAULT 0,
  `submitted_count`INT          DEFAULT 0,
  `date_submitted` DATE         DEFAULT NULL,
  `remarks`        TEXT         DEFAULT NULL,
  `generated_by`   INT          DEFAULT NULL,
  `generated_at`   DATETIME     DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_department` (`department`),
  INDEX `idx_period`     (`period_start`, `period_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 9. MODULE PERMISSIONS — seed defaults for all roles
-- ============================================================
CREATE TABLE IF NOT EXISTS `module_permissions` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `module`     VARCHAR(80)   NOT NULL,
  `role`       VARCHAR(40)   NOT NULL,
  `action`     VARCHAR(30)   NOT NULL,
  `granted`    TINYINT(1)    NOT NULL DEFAULT 1,
  `updated_by` VARCHAR(100)  DEFAULT NULL,
  `updated_at` TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_module_role_action` (`module`, `role`, `action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed default permissions (Admin role — standard access)
INSERT IGNORE INTO `module_permissions` (`module`, `role`, `action`, `granted`) VALUES
-- Employee Masterlist
('Employee Masterlist','Admin','View',1),('Employee Masterlist','Admin','Add',1),
('Employee Masterlist','Admin','Edit',1),('Employee Masterlist','Admin','Delete',0),
('Employee Masterlist','Admin','Export',1),
('Employee Masterlist','Super Admin','View',1),('Employee Masterlist','Super Admin','Add',1),
('Employee Masterlist','Super Admin','Edit',1),('Employee Masterlist','Super Admin','Delete',1),
('Employee Masterlist','Super Admin','Export',1),
('Employee Masterlist','Section Admin','View',1),('Employee Masterlist','Section Admin','Add',0),
('Employee Masterlist','Section Admin','Edit',0),('Employee Masterlist','Section Admin','Delete',0),
-- Leave Management
('Leave Management','Admin','View',1),('Leave Management','Admin','Add',1),
('Leave Management','Admin','Edit',1),('Leave Management','Admin','Delete',0),
('Leave Management','Admin','Approve',1),
('Leave Management','Super Admin','View',1),('Leave Management','Super Admin','Add',1),
('Leave Management','Super Admin','Edit',1),('Leave Management','Super Admin','Delete',1),
('Leave Management','Super Admin','Approve',1),
('Leave Management','Section Admin','View',1),('Leave Management','Section Admin','Add',0),
('Leave Management','Section Admin','Edit',0),('Leave Management','Section Admin','Delete',0),
-- Schedule Database
('Schedule Database','Admin','View',1),('Schedule Database','Admin','Add',1),
('Schedule Database','Admin','Edit',1),('Schedule Database','Admin','Delete',0),
('Schedule Database','Admin','Export',1),
('Schedule Database','Super Admin','View',1),('Schedule Database','Super Admin','Add',1),
('Schedule Database','Super Admin','Edit',1),('Schedule Database','Super Admin','Delete',1),
('Schedule Database','Super Admin','Export',1),
('Schedule Database','Section Admin','View',1),('Schedule Database','Section Admin','Add',1),
('Schedule Database','Section Admin','Edit',1),('Schedule Database','Section Admin','Delete',0),
-- Trainings
('Trainings','Admin','View',1),('Trainings','Admin','Add',1),
('Trainings','Admin','Edit',1),('Trainings','Admin','Delete',0),
('Trainings','Super Admin','View',1),('Trainings','Super Admin','Add',1),
('Trainings','Super Admin','Edit',1),('Trainings','Super Admin','Delete',1),
-- Account Management
('Account Management','Admin','View',1),('Account Management','Admin','Add',0),
('Account Management','Admin','Edit',0),('Account Management','Admin','Delete',0),
('Account Management','Super Admin','View',1),('Account Management','Super Admin','Add',1),
('Account Management','Super Admin','Edit',1),('Account Management','Super Admin','Delete',0),
-- AI Scanning Tools
('AI Scanning Tools','Admin','View',1),('AI Scanning Tools','Admin','Upload',1),
('AI Scanning Tools','Admin','Delete',0),
('AI Scanning Tools','Super Admin','View',1),('AI Scanning Tools','Super Admin','Upload',1),
('AI Scanning Tools','Super Admin','Delete',1),
-- PRC Licenses
('PRC Licenses','Admin','View',1),('PRC Licenses','Admin','Add',1),
('PRC Licenses','Admin','Edit',1),('PRC Licenses','Admin','Delete',0),
('PRC Licenses','Super Admin','View',1),('PRC Licenses','Super Admin','Add',1),
('PRC Licenses','Super Admin','Edit',1),('PRC Licenses','Super Admin','Delete',1),
-- DTR Transmittal
('DTR Transmittal','Admin','View',1),('DTR Transmittal','Admin','Add',1),
('DTR Transmittal','Admin','Edit',1),('DTR Transmittal','Admin','Delete',0),
('DTR Transmittal','Admin','Verify',1),
('DTR Transmittal','Super Admin','View',1),('DTR Transmittal','Super Admin','Add',1),
('DTR Transmittal','Super Admin','Edit',1),('DTR Transmittal','Super Admin','Delete',1),
('DTR Transmittal','Super Admin','Verify',1),
-- Travel Orders
('Travel Orders','Admin','View',1),('Travel Orders','Admin','Add',1),
('Travel Orders','Admin','Edit',1),('Travel Orders','Admin','Delete',0),
('Travel Orders','Admin','Approve',1),
('Travel Orders','Super Admin','View',1),('Travel Orders','Super Admin','Add',1),
('Travel Orders','Super Admin','Edit',1),('Travel Orders','Super Admin','Delete',1),
('Travel Orders','Super Admin','Approve',1),
-- Audit History
('Audit History','Admin','View',1),('Audit History','Admin','Export',1),
('Audit History','Super Admin','View',1),('Audit History','Super Admin','Export',1),
-- Departments
('Departments','Admin','View',1),('Departments','Admin','Add',1),
('Departments','Admin','Edit',1),('Departments','Admin','Delete',0),
('Departments','Super Admin','View',1),('Departments','Super Admin','Add',1),
('Departments','Super Admin','Edit',1),('Departments','Super Admin','Delete',1),
-- Birthday Celebrants
('Birthday Celebrants','Admin','View',1),('Birthday Celebrants','Admin','Export',1),
('Birthday Celebrants','Super Admin','View',1),('Birthday Celebrants','Super Admin','Export',1),
('Birthday Celebrants','Section Admin','View',1),
-- Tracking / Receiving
('Tracking / Receiving','Admin','View',1),('Tracking / Receiving','Admin','Add',1),
('Tracking / Receiving','Admin','Edit',1),('Tracking / Receiving','Admin','Delete',0),
('Tracking / Receiving','Super Admin','View',1),('Tracking / Receiving','Super Admin','Add',1),
('Tracking / Receiving','Super Admin','Edit',1),('Tracking / Receiving','Super Admin','Delete',1),
-- Signatories
('Signatories','Admin','View',1),('Signatories','Admin','Add',1),
('Signatories','Admin','Edit',1),('Signatories','Admin','Delete',0),
('Signatories','Super Admin','View',1),('Signatories','Super Admin','Add',1),
('Signatories','Super Admin','Edit',1),('Signatories','Super Admin','Delete',1),
-- Audit Transmittal
('Audit Transmittal','Admin','View',1),('Audit Transmittal','Admin','Export',1),
('Audit Transmittal','Super Admin','View',1),('Audit Transmittal','Super Admin','Export',1),
-- Verification
('Verification','Admin','View',1),('Verification','Admin','Verify',1),
('Verification','Super Admin','View',1),('Verification','Super Admin','Verify',1);

-- ============================================================
-- 10. SAMPLE PRC LICENSE DATA (for testing)
-- ============================================================
-- Only inserts if employees exist with matching IDs
-- Uncomment and adjust employee_id values as needed:
-- INSERT IGNORE INTO prc_licenses (employee_id, license_number, expiry_date, remarks)
-- SELECT id, CONCAT('PRC-', LPAD(id, 6, '0')), DATE_ADD(CURDATE(), INTERVAL 2 YEAR), 'Active License'
-- FROM employees WHERE position LIKE '%Nurse%' OR position LIKE '%Medical Tech%' OR position LIKE '%Pharmacist%'
-- LIMIT 20;

-- ============================================================
-- 11. VERIFICATION — show table counts
-- ============================================================
SELECT 'users'               AS `table`, COUNT(*) AS `rows` FROM users
UNION ALL SELECT 'employees',            COUNT(*) FROM employees
UNION ALL SELECT 'departments',          COUNT(*) FROM departments
UNION ALL SELECT 'shift_legends',        COUNT(*) FROM shift_legends
UNION ALL SELECT 'module_permissions',   COUNT(*) FROM module_permissions
UNION ALL SELECT 'prc_licenses',         COUNT(*) FROM prc_licenses
UNION ALL SELECT 'ai_scanned_docs',      COUNT(*) FROM ai_scanned_docs;
