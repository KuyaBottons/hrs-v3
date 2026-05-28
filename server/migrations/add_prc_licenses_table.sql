-- Create PRC Licenses table
CREATE TABLE IF NOT EXISTS prc_licenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT(10) UNSIGNED NOT NULL,
    license_number VARCHAR(100) NOT NULL,
    expiry_date DATE NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    UNIQUE KEY (employee_id, license_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Add index for faster queries
CREATE INDEX idx_prc_employee_id ON prc_licenses(employee_id);
CREATE INDEX idx_prc_expiry_date ON prc_licenses(expiry_date);
