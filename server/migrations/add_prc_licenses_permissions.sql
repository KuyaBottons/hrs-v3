-- Add default permissions for PRC Licenses module
-- Grant full access to DIOS and Admin roles
INSERT INTO module_permissions (module, role, action, granted, updated_by) VALUES
('PRC Licenses', 'DIOS', 'View', 1, 'DIOS'),
('PRC Licenses', 'DIOS', 'Add', 1, 'DIOS'),
('PRC Licenses', 'DIOS', 'Edit', 1, 'DIOS'),
('PRC Licenses', 'DIOS', 'Delete', 1, 'DIOS'),
('PRC Licenses', 'Admin', 'View', 1, 'DIOS'),
('PRC Licenses', 'Admin', 'Add', 1, 'DIOS'),
('PRC Licenses', 'Admin', 'Edit', 1, 'DIOS'),
('PRC Licenses', 'Admin', 'Delete', 1, 'DIOS'),
('PRC Licenses', 'Super Admin', 'View', 1, 'DIOS'),
('PRC Licenses', 'Super Admin', 'Add', 1, 'DIOS'),
('PRC Licenses', 'Super Admin', 'Edit', 1, 'DIOS'),
('PRC Licenses', 'Super Admin', 'Delete', 1, 'DIOS')
ON DUPLICATE KEY UPDATE granted = VALUES(granted);
