-- Add biometrics_number column to users table
-- This allows users to login with either username or biometrics number

USE `geamh_hris`;

ALTER TABLE `users`
ADD COLUMN IF NOT EXISTS `biometrics_number` VARCHAR(4) NULL AFTER `username`,
ADD UNIQUE INDEX IF NOT EXISTS `idx_biometrics_number` (`biometrics_number`);

-- Add comment to the column
ALTER TABLE `users`
MODIFY COLUMN `biometrics_number` VARCHAR(4) NULL COMMENT 'Biometrics number for login (max 4 digits)';
