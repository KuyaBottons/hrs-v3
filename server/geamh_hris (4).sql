-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 28, 2026 at 10:28 AM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `geamh_hris`
--

-- --------------------------------------------------------

--
-- Table structure for table `ai_scanned_docs`
--

CREATE TABLE `ai_scanned_docs` (
  `id` int(10) UNSIGNED NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `doc_type` enum('DTR','Leave Form','Payslip','Travel Order','Schedule','Unknown') NOT NULL DEFAULT 'Unknown',
  `file_size` varchar(20) DEFAULT NULL,
  `file_path` varchar(500) DEFAULT NULL,
  `confidence` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'OCR confidence 0-100',
  `extracted_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Key-value pairs from OCR' CHECK (json_valid(`extracted_data`)),
  `raw_text` mediumtext DEFAULT NULL,
  `status` enum('Processing','Processed','Review Needed') NOT NULL DEFAULT 'Processing',
  `uploaded_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `user_name` varchar(100) NOT NULL,
  `action` varchar(100) NOT NULL COMMENT 'e.g. Login, DTR Received, Employee Added',
  `action_type` enum('LOGIN','LOGOUT','CREATE','UPDATE','DELETE','VIEW','EXPORT','OTHER') NOT NULL DEFAULT 'OTHER' COMMENT 'Standardised action category',
  `module` enum('DTR','Leave','Payroll','Employee','T.O.','Auth','Schedule','Training','Tracking','Signatory','Department','Account','Other') NOT NULL DEFAULT 'Other',
  `affected_table` varchar(60) DEFAULT NULL COMMENT 'DB table affected e.g. employees',
  `record_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'PK of the affected row',
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Snapshot before change' CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Snapshot after change' CHECK (json_valid(`new_values`)),
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'Client IP (IPv4 or IPv6)',
  `details` text DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'OK',
  `archived` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `user_id`, `user_name`, `action`, `action_type`, `module`, `affected_table`, `record_id`, `old_values`, `new_values`, `ip_address`, `details`, `status`, `archived`, `created_at`) VALUES
(1, 1, 'Super Admin', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Agrimano, Rheanbelle updated.', 'OK', 0, '2026-05-04 07:08:40'),
(2, 1, 'Super Admin', 'Sign Up', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'New user DIOS (dios123) registered.', 'OK', 0, '2026-05-05 03:02:42'),
(3, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-05 03:03:05'),
(4, 4294967295, 'DIOS', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS logged in.', 'OK', 0, '2026-05-05 03:03:08'),
(5, 4294967295, 'DIOS', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS logged in.', 'OK', 0, '2026-05-05 03:06:35'),
(6, 4294967295, 'DIOS', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS logged out.', 'OK', 0, '2026-05-05 03:06:56'),
(7, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-05 03:07:03'),
(8, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-05 05:33:53'),
(9, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-05 05:34:04'),
(10, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-07 02:03:41'),
(11, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-07 02:10:36'),
(12, 1, 'Super Admin', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Abaredes, Malayas updated.', 'OK', 0, '2026-05-07 02:39:41'),
(13, 1, 'Super Admin', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 269, NULL, '{\"employeeNo\":\"KPFH-C080\",\"lastName\":\"Abaredes\",\"firstName\":\"Malaya\",\"middleName\":\"A.\",\"position\":\"Nursing Attendant I\",\"department\":\"Nursing\",\"employmentStatus\":\"Casual\",\"dateHired\":\"\",\"birthDate\":\"\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":269}', '::1', 'Abaredes, Malaya was updated.', 'OK', 0, '2026-05-07 03:14:43'),
(14, 1, 'Super Admin', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Abaredes, Malaya updated.', 'OK', 0, '2026-05-07 03:14:43'),
(15, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-07 03:20:11'),
(16, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-07 03:21:11'),
(17, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-07 03:21:26'),
(18, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-07 03:25:40'),
(19, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-07 04:59:17'),
(20, 1, 'Super Admin', 'Schedule Updated', 'UPDATE', 'Schedule', 'schedules', 3, '0', '{\"id\":\"3\",\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle\",\"department\":\"Information Technology\",\"shift\":\"Morning\",\"shiftTime\":\"07:00 AM - 03:00 PM\",\"days\":[\"Mon\",\"Tue\",\"Wed\",\"Thu\",\"Sun\"],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"Fri, Sat\"}', '::1', 'Agrimano, Rheanbelle was updated.', 'OK', 0, '2026-05-07 05:13:19'),
(21, 1, 'Super Admin', 'Schedule Updated', 'UPDATE', 'Schedule', 'schedules', 3, '0', '{\"id\":\"3\",\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle\",\"department\":\"Information Technology\",\"shift\":\"Morning\",\"shiftTime\":\"07:00 AM - 03:00 PM\",\"days\":[\"Mon\",\"Tue\",\"Wed\",\"Thu\",\"Sun\"],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"Fri, Sat\"}', '::1', 'Agrimano, Rheanbelle was updated.', 'OK', 0, '2026-05-07 05:13:20'),
(22, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-07 05:15:07'),
(23, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-07 05:30:27'),
(24, 1, 'Super Admin', 'Profile Change Requested', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin requested a profile update. Awaiting approval.', 'OK', 0, '2026-05-07 05:44:00'),
(25, 1, 'Super Admin', 'Profile Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin updated their profile.', 'OK', 0, '2026-05-07 05:48:26'),
(26, 1, 'Super Admin', 'Profile Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin updated their profile.', 'OK', 0, '2026-05-07 05:48:36'),
(27, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-07 05:56:50'),
(28, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-07 06:55:35'),
(29, 1, 'Super Admin', 'Employee Deleted', 'DELETE', 'Employee', 'employees', 365, '0', NULL, '::1', 'Cadavid, Francine was deleted.', 'OK', 0, '2026-05-07 07:47:16'),
(30, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-07 08:18:16'),
(31, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-07 08:18:28'),
(32, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-07 08:21:14'),
(33, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-07 08:29:20'),
(34, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-07 08:35:10'),
(35, 2, 'HR Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'HR Admin logged in.', 'OK', 0, '2026-05-08 00:30:50'),
(36, 2, 'HR Admin', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Abaredes, Malaya updated.', 'OK', 0, '2026-05-08 01:19:24'),
(37, 2, 'HR Admin', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 269, NULL, '{\"employeeNo\":\"KPFH-C080\",\"lastName\":\"Abaredes\",\"firstName\":\"Malaya\",\"middleName\":\"A.\",\"position\":\"Nursing Attendant I\",\"department\":\"Nursing\",\"employmentStatus\":\"Casual\",\"dateHired\":\"2010-02-08\",\"birthDate\":\"\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":269}', '::1', 'Abaredes, Malaya was updated.', 'OK', 0, '2026-05-08 01:19:24'),
(38, 2, 'HR Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'HR Admin logged in.', 'OK', 0, '2026-05-08 05:34:17'),
(39, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-08 06:10:28'),
(40, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-08 06:10:34'),
(41, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-08 06:11:09'),
(42, 1, 'Super Admin', 'Leave Added', 'CREATE', 'Leave', 'leave_records', 4, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle C.\",\"department\":\"Information Technology\",\"leaveType\":\"Sick Leave\",\"dateFrom\":\"2026-05-30\",\"dateTo\":\"2026-05-30\",\"days\":1,\"reason\":\"nangungulila\",\"status\":\"Pending\",\"approvedBy\":\"\",\"dateApproved\":\"\",\"remarks\":\"ahuhuhuhu\",\"id\":4}', '::1', 'Agrimano, Rheanbelle C. was added.', 'OK', 0, '2026-05-08 06:32:23'),
(43, 1, 'Super Admin', 'Leave Deleted', 'DELETE', 'Leave', 'leave_records', 4, '0', NULL, '::1', 'Agrimano, Rheanbelle C. was deleted.', 'OK', 0, '2026-05-08 06:38:48'),
(44, 1, 'Super Admin', 'Leave Added', 'CREATE', 'Leave', 'leave_records', 5, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle C.\",\"department\":\"Information Technology\",\"leaveType\":\"Sick Leave\",\"dateFrom\":\"2026-05-30\",\"dateTo\":\"2026-05-30\",\"days\":1,\"reason\":\"nangungulila\",\"status\":\"Pending\",\"approvedBy\":\"\",\"dateApproved\":\"\",\"remarks\":\"ahuhauhauhauhauh\\n\",\"id\":5}', '::1', 'Agrimano, Rheanbelle C. was added.', 'OK', 0, '2026-05-08 06:42:58'),
(45, 1, 'Super Admin', 'Leave Deleted', 'DELETE', 'Leave', 'leave_records', 3, '0', NULL, '::1', 'Bautista, Ana C. was deleted.', 'OK', 0, '2026-05-08 06:43:03'),
(46, 1, 'Super Admin', 'Leave Deleted', 'DELETE', 'Leave', 'leave_records', 2, '0', NULL, '::1', 'Santos, Pedro L. was deleted.', 'OK', 0, '2026-05-08 06:43:07'),
(47, 1, 'Super Admin', 'Leave Deleted', 'DELETE', 'Leave', 'leave_records', 1, '0', NULL, '::1', 'Dela Cruz, Juan S. was deleted.', 'OK', 0, '2026-05-08 06:43:11'),
(48, 1, 'Super Admin', 'Leave Deleted', 'DELETE', 'Leave', 'leave_records', 1, '0', NULL, '::1', 'Test, User was deleted.', 'OK', 0, '2026-05-08 07:20:11'),
(49, 1, 'Super Admin', 'Leave Added', 'CREATE', 'Leave', 'leave_records', 3, NULL, '{\"id\":3,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle C.\",\"department\":\"Information Technology\",\"leaveType\":\"Vacation Leave\",\"dateFrom\":\"2026-05-30\",\"dateTo\":\"2026-05-30\",\"days\":1,\"reason\":\"\",\"status\":\"Pending\",\"approvedBy\":\"\",\"dateApproved\":\"\",\"remarks\":\"\"}', '::1', 'Agrimano, Rheanbelle C. was added.', 'OK', 0, '2026-05-08 07:20:27'),
(50, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-09 01:13:27'),
(51, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-09 01:22:59'),
(52, 2, 'HR Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'HR Admin logged in.', 'OK', 0, '2026-05-09 01:23:11'),
(53, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-09 02:59:38'),
(54, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-09 03:07:26'),
(55, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-09 03:11:57'),
(56, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-09 03:17:12'),
(57, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-09 03:23:39'),
(58, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-09 03:50:53'),
(59, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-09 05:48:27'),
(60, 1, 'Super Admin', 'Employee Added', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'New employee Sismaet, Angeline added.', 'OK', 0, '2026-05-09 05:50:37'),
(61, 1, 'Super Admin', 'Employee Added', 'CREATE', 'Employee', 'employees', 366, NULL, '{\"id\":\"366\",\"employeeNo\":\"GEAMH-666\",\"lastName\":\"Sismaet\",\"firstName\":\"Angeline\",\"middleName\":\"Dondoyano\",\"position\":\"\",\"designation\":\"\",\"department\":\"\",\"employmentStatus\":\"Permanent\",\"dateHired\":\"\",\"birthDate\":\"2004-10-06\",\"age\":\"0\",\"gender\":\"Female\",\"civilStatus\":\"Married\",\"address\":\"Ormoc City\",\"contactNo\":\"09909090900\",\"email\":\"angel@geamh.gov.ph\",\"salary\":0,\"sgStep\":\"\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true}', '::1', 'Sismaet, Angeline was added.', 'OK', 0, '2026-05-09 05:50:37'),
(62, 1, 'Super Admin', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 366, NULL, '{\"employeeNo\":\"GEAMH-666\",\"lastName\":\"Sismaet\",\"firstName\":\"Angeline\",\"middleName\":\"Dondoyano\",\"position\":\"Nurse IV\",\"department\":\"Nursing\",\"employmentStatus\":\"Part Time\",\"dateHired\":\"2026-02-25\",\"birthDate\":\"2004-10-06\",\"gender\":\"Female\",\"civilStatus\":\"Married\",\"address\":\"Ormoc City\",\"contactNo\":\"09909090900\",\"email\":\"angel@geamh.gov.ph\",\"salary\":0,\"sgStep\":\"\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":366}', '::1', 'Sismaet, Angeline was updated.', 'OK', 0, '2026-05-09 05:52:55'),
(63, 1, 'Super Admin', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Sismaet, Angeline updated.', 'OK', 0, '2026-05-09 05:52:55'),
(64, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-09 06:46:39'),
(65, 1, 'Super Admin', 'Leave Added', 'CREATE', 'Leave', 'leave_records', NULL, NULL, '{\"employee_id\":\"366\",\"employee_no\":\"GEAMH-666\",\"employee_name\":\"Sismaet, Angeline Dondoyano\",\"department\":\"Nursing\",\"leave_type\":\"Forced Leave\",\"date_from\":\"2026-05-11\",\"date_to\":\"2026-05-19\",\"days\":8,\"reason\":\"\",\"status\":\"Disapproved\",\"approved_by\":\"Francine\",\"date_approved\":\"2026-05-09\",\"remarks\":\"\"}', '::1', 'Sismaet, Angeline Dondoyano was added.', 'OK', 0, '2026-05-09 06:48:55'),
(66, 1, 'Super Admin', 'Leave Updated', 'UPDATE', 'Leave', 'leave_records', 4, '0', '{\"id\":\"4\",\"employee_id\":\"366\",\"employee_no\":\"GEAMH-666\",\"employee_name\":\"Sismaet, Angeline Dondoyano\",\"department\":\"Nursing\",\"leave_type\":\"Forced Leave\",\"date_from\":\"2026-05-11\",\"date_to\":\"2026-05-19\",\"days\":\"8.0\",\"reason\":\"\",\"status\":\"Disapproved\",\"approved_by\":\"Francine\",\"date_approved\":\"2026-05-09\",\"remarks\":\"\",\"created_at\":\"2026-05-09 14:48:55\",\"updated_at\":\"2026-05-09 14:48:55\",\"employeeId\":\"366\",\"employeeNo\":\"GEAMH-666\",\"employeeName\":\"Sismaet, Angeline Dondoyano\"}', '::1', 'Sismaet, Angeline Dondoyano was updated.', 'OK', 0, '2026-05-09 06:50:11'),
(67, 1, 'Super Admin', 'Leave Updated', 'UPDATE', 'Leave', 'leave_records', 4, '0', '{\"id\":4,\"employeeId\":366,\"employeeNo\":\"GEAMH-666\",\"employeeName\":\"Sismaet, Angeline Dondoyano\",\"department\":\"Nursing\",\"leaveType\":\"Forced Leave\",\"dateFrom\":\"0000-00-00\",\"dateTo\":\"0000-00-00\",\"days\":8,\"reason\":\"\",\"status\":\"Disapproved\",\"approvedBy\":null,\"dateApproved\":null,\"remarks\":\"\"}', '::1', 'Sismaet, Angeline Dondoyano was updated.', 'OK', 0, '2026-05-09 06:52:05'),
(68, 1, 'Super Admin', 'Leave Updated', 'UPDATE', 'Leave', 'leave_records', 4, '0', '{\"id\":4,\"employeeId\":366,\"employeeNo\":\"GEAMH-666\",\"employeeName\":\"Sismaet, Angeline Dondoyano\",\"department\":\"Nursing\",\"leaveType\":\"Forced Leave\",\"dateFrom\":\"0000-00-00\",\"dateTo\":\"0000-00-00\",\"days\":8,\"reason\":\"\",\"status\":\"Pending\",\"approvedBy\":null,\"dateApproved\":null,\"remarks\":\"\"}', '::1', 'Sismaet, Angeline Dondoyano was updated.', 'OK', 0, '2026-05-09 06:57:28'),
(69, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-09 07:17:09'),
(70, 1, 'Super Admin', 'Travel Order Added', 'CREATE', '', 'travel order', NULL, NULL, '{\"employee_id\":null,\"employee_no\":\"666\",\"employee_name\":\"Angeline\",\"department\":\"Nursing\",\"destination\":\"Ecert\",\"purpose\":\"secret\",\"date_from\":\"\",\"date_to\":\"\",\"days\":1,\"transport\":\"Public Transport\",\"approved_by\":null,\"status\":\"Pending\",\"remarks\":\"\"}', '::1', 'Angeline was added.', 'OK', 0, '2026-05-09 08:14:48'),
(71, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-10 17:57:07'),
(72, 1, 'Super Admin', 'Signatory Updated', 'UPDATE', 'Signatory', 'signatories', 5, '0', '{\"id\":\"5\",\"name\":\"Thea Villanueva\",\"position\":\"HR Clerk II\",\"role\":\"DTR Processor\",\"department\":\"Human Resources\",\"order\":5,\"active\":false}', '::1', 'Thea Villanueva was updated.', 'OK', 0, '2026-05-10 18:00:33'),
(73, 1, 'Super Admin', 'Signatory Updated', 'UPDATE', 'Signatory', 'signatories', 5, '0', '{\"id\":\"5\",\"name\":\"Thea Villanueva\",\"position\":\"HR Clerk II\",\"role\":\"DTR Processor\",\"department\":\"Human Resources\",\"order\":5,\"active\":true}', '::1', 'Thea Villanueva was updated.', 'OK', 0, '2026-05-10 18:00:47'),
(74, 1, 'Super Admin', 'Employee Added', 'CREATE', 'Employee', 'employees', 367, NULL, '{\"id\":\"367\",\"employeeNo\":\"000\",\"lastName\":\"Mico\",\"firstName\":\"m\",\"middleName\":\"m\",\"position\":\"\",\"designation\":\"\",\"department\":\"\",\"employmentStatus\":\"Permanent\",\"dateHired\":\"\",\"birthDate\":\"\",\"age\":\"0\",\"gender\":\"Male\",\"civilStatus\":\"Single\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true}', '::1', 'Mico, m was added.', 'OK', 0, '2026-05-10 18:47:24'),
(75, 1, 'Super Admin', 'Employee Added', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'New employee Mico, m added.', 'OK', 0, '2026-05-10 18:47:24'),
(76, 1, 'Super Admin', 'Employee Deleted', 'DELETE', 'Employee', 'employees', 367, '0', NULL, '::1', 'Mico, m was deleted.', 'OK', 0, '2026-05-10 18:47:34'),
(77, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-11 01:52:34'),
(78, 1, 'Super Admin', 'DTR Added', 'CREATE', 'DTR', 'dtr_records', 1, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle C.\",\"department\":\"Information Technology\",\"period\":\"April 1-15, 2026\",\"transmittalType\":\"Main\",\"submittedBy\":\"basta\",\"dateSubmitted\":\"2026-05-11\",\"dateReceived\":\"2026-05-11\",\"verifiedBy\":\"basta\",\"verificationDate\":\"2026-05-11\",\"status\":\"Submitted\",\"remarks\":\"oks sha\",\"signatories\":[],\"signedBy\":[],\"processedBy\":\"Super Admin\",\"id\":1}', '::1', 'Agrimano, Rheanbelle C. was added.', 'OK', 0, '2026-05-11 02:23:04'),
(79, 1, 'Super Admin', 'DTR Added', 'OTHER', 'DTR', NULL, NULL, NULL, NULL, '::1', 'DTR of Agrimano, Rheanbelle C. (April 1-15, 2026) added.', 'OK', 0, '2026-05-11 02:23:04'),
(80, 1, 'Super Admin', 'Document Tracking Added', 'CREATE', '', 'document tracking', NULL, NULL, '{\"doc_type\":\"Travel Order\",\"doc_no\":\"123\",\"from_office\":\"me\",\"to_office\":\"HR Office\",\"date_forwarded\":\"2026-05-11\",\"date_received\":null,\"received_by\":\"Gonzales, Realyn P. (HR AMELA)\",\"status\":\"Pending\",\"remarks\":\"\"}', '::1', '123 was added.', 'OK', 0, '2026-05-11 02:39:16'),
(81, 1, 'Super Admin', 'Document Tracking Updated', 'UPDATE', '', 'document tracking', 1, '0', '{\"id\":\"1\",\"docType\":\"Travel Order\",\"docNo\":\"123\",\"from\":\"me\",\"to\":\"HR Office\",\"dateForwarded\":\"2026-05-11\",\"dateReceived\":\"2026-05-11\",\"receivedBy\":\"Gonzales, Realyn P. (HR AMELA)\",\"status\":\"Received\",\"remarks\":\"\"}', '::1', '123 was updated.', 'OK', 0, '2026-05-11 02:42:51'),
(82, 1, 'Super Admin', 'Signatory Updated', 'UPDATE', 'Signatory', 'signatories', 5, '0', '{\"id\":\"5\",\"name\":\"Thea Villanueva\",\"position\":\"HR Clerk II\",\"role\":\"DTR Processor\",\"department\":\"Human Resources\",\"order\":5,\"active\":false}', '::1', 'Thea Villanueva was updated.', 'OK', 0, '2026-05-11 02:43:25'),
(83, 1, 'Super Admin', 'Signatory Updated', 'UPDATE', 'Signatory', 'signatories', 5, '0', '{\"id\":\"5\",\"name\":\"Thea Villanueva\",\"position\":\"HR Clerk II\",\"role\":\"DTR Processor\",\"department\":\"Human Resources\",\"order\":5,\"active\":true}', '::1', 'Thea Villanueva was updated.', 'OK', 0, '2026-05-11 02:43:44'),
(84, 3, 'DIOS User', 'Document Tracking Added', 'CREATE', '', 'document tracking', NULL, NULL, '{\"doc_type\":\"DTR Transmittal\",\"doc_no\":\"76543\",\"from_office\":\"HR Office\",\"to_office\":\"jhgfd\",\"date_forwarded\":\"2026-05-11\",\"date_received\":null,\"received_by\":null,\"status\":\"Sent\",\"remarks\":\"\"}', '::1', '76543 was added.', 'OK', 0, '2026-05-11 03:18:25'),
(85, 3, 'DIOS User', 'Signatory Updated', 'UPDATE', 'Signatory', 'signatories', 2, '0', '{\"id\":\"2\",\"name\":\"Mr. Jose Santos\",\"position\":\"HR Officer IV\",\"role\":\"HR Approver\",\"department\":\"Human Resources\",\"order\":2,\"active\":false}', '::1', 'Mr. Jose Santos was updated.', 'OK', 0, '2026-05-11 03:18:50'),
(86, 3, 'DIOS User', 'Signatory Updated', 'UPDATE', 'Signatory', 'signatories', 2, '0', '{\"id\":\"2\",\"name\":\"Mr. Jose Santos\",\"position\":\"HR Officer IV\",\"role\":\"HR Approver\",\"department\":\"Human Resources\",\"order\":2,\"active\":true}', '::1', 'Mr. Jose Santos was updated.', 'OK', 0, '2026-05-11 03:18:51'),
(87, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-12 01:42:08'),
(88, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-12 01:42:17'),
(89, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-12 01:45:19'),
(90, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-12 02:54:42'),
(91, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-12 03:02:40'),
(92, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-12 06:44:38'),
(93, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-12 06:57:53'),
(94, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-12 06:58:50'),
(95, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-12 06:59:03'),
(96, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-12 06:59:14'),
(97, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-12 06:59:24'),
(98, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-12 07:13:56'),
(99, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-12 07:14:12'),
(100, 1, 'Super Admin', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 269, NULL, '{\"employeeNo\":\"KPFH-C080\",\"lastName\":\"Abaredes\",\"firstName\":\"Malayas\",\"middleName\":\"A.\",\"position\":\"Nursing Attendant I\",\"department\":\"Nursing\",\"employmentStatus\":\"Casual\",\"dateHired\":\"2010-02-08\",\"birthDate\":\"\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":269}', '::1', 'Abaredes, Malayas was updated.', 'OK', 0, '2026-05-12 07:14:38'),
(101, 1, 'Super Admin', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Abaredes, Malayas updated.', 'OK', 0, '2026-05-12 07:14:38'),
(102, 1, 'Super Admin', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 269, NULL, '{\"employeeNo\":\"KPFH-C080\",\"lastName\":\"Abaredes\",\"firstName\":\"Malaya\",\"middleName\":\"A.\",\"position\":\"Nursing Attendant I\",\"department\":\"Nursing\",\"employmentStatus\":\"Casual\",\"dateHired\":\"2010-02-08\",\"birthDate\":\"\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":269}', '::1', 'Abaredes, Malaya was updated.', 'OK', 0, '2026-05-12 07:14:49'),
(103, 1, 'Super Admin', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Abaredes, Malaya updated.', 'OK', 0, '2026-05-12 07:14:49'),
(104, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-12 07:15:53'),
(105, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-12 07:16:07'),
(106, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-12 08:05:19'),
(107, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-12 08:05:41'),
(108, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-13 00:35:07'),
(109, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-13 00:55:34'),
(110, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-13 03:23:55'),
(111, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-13 03:28:51'),
(112, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-13 05:50:54'),
(113, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-13 05:52:11'),
(114, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-13 06:42:42'),
(115, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-13 06:42:55'),
(116, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-13 06:46:55'),
(117, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-13 06:47:05'),
(118, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Abaredes, Malayas updated.', 'OK', 0, '2026-05-13 07:00:18'),
(119, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 269, NULL, '{\"employeeNo\":\"KPFH-C080\",\"lastName\":\"Abaredes\",\"firstName\":\"Malayas\",\"middleName\":\"A.\",\"position\":\"Nursing Attendant I\",\"department\":\"Nursing\",\"employmentStatus\":\"Casual\",\"dateHired\":\"2010-02-08\",\"birthDate\":\"\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":269}', '::1', 'Abaredes, Malayas was updated.', 'OK', 0, '2026-05-13 07:00:18'),
(120, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 269, NULL, '{\"employeeNo\":\"KPFH-C080\",\"lastName\":\"Abaredes\",\"firstName\":\"Malaya\",\"middleName\":\"A.\",\"position\":\"Nursing Attendant I\",\"department\":\"Nursing\",\"employmentStatus\":\"Casual\",\"dateHired\":\"2010-02-08\",\"birthDate\":\"\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":269}', '::1', 'Abaredes, Malaya was updated.', 'OK', 0, '2026-05-13 07:01:12'),
(121, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Abaredes, Malaya updated.', 'OK', 0, '2026-05-13 07:01:12'),
(122, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 6, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"lastName\":\"Agrimano\",\"firstName\":\"Rheanbelle mae\",\"middleName\":\"C.\",\"position\":\"Administrative Aide III\",\"department\":\"Information Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"\",\"birthDate\":\"2002-05-30\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":6}', '::1', 'Agrimano, Rheanbelle mae was updated.', 'OK', 0, '2026-05-13 07:01:26'),
(123, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Agrimano, Rheanbelle mae updated.', 'OK', 0, '2026-05-13 07:01:26'),
(124, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 6, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"lastName\":\"Agrimano\",\"firstName\":\"Rheanbelle \",\"middleName\":\"C.\",\"position\":\"Administrative Aide III\",\"department\":\"Information Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"\",\"birthDate\":\"2002-05-30\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":6}', '::1', 'Agrimano, Rheanbelle  was updated.', 'OK', 0, '2026-05-13 07:02:12'),
(125, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Agrimano, Rheanbelle  updated.', 'OK', 0, '2026-05-13 07:02:12'),
(126, 3, 'DIOS User', 'Sign Up', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'New user Test Admin (test 0000) registered.', 'OK', 0, '2026-05-13 07:11:02'),
(127, 3, 'DIOS User', 'User Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User Test Admin updated.', 'OK', 0, '2026-05-13 07:11:10'),
(128, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-13 07:11:52'),
(129, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-13 07:12:00'),
(130, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-13 07:12:00'),
(131, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-14 00:25:01'),
(132, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-14 00:25:01'),
(133, 3, 'DIOS User', 'User Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User Test Admin updated.', 'OK', 0, '2026-05-14 00:27:58'),
(134, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-14 00:28:05'),
(135, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-14 00:28:34'),
(136, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-14 00:28:34'),
(137, 3, 'DIOS User', 'User Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User Test Admin updated.', 'OK', 0, '2026-05-14 00:28:57'),
(138, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-14 00:29:02'),
(139, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-14 00:29:29'),
(140, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-14 00:29:29'),
(141, 3, 'DIOS User', 'User Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User Test Admin updated.', 'OK', 0, '2026-05-14 00:32:07'),
(142, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-14 00:32:11'),
(143, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-14 00:32:30'),
(144, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-14 00:32:30'),
(145, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-14 01:23:25'),
(146, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-14 01:23:25'),
(147, 4, 'Test Admin', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 6, NULL, '{\"id\":\"6\",\"employeeNo\":\"KPFH-C080\",\"employeeName\":\"Abaredes, Malaya\",\"department\":\"Nursing\",\"shift\":\"Morning\",\"shiftTime\":\"07:00 AM - 03:00 PM\",\"days\":[\"Mon\",\"Tue\",\"Wed\",\"Thu\",\"Sat\"],\"effectiveDate\":\"2026-05-18\",\"endDate\":\"2026-05-23\",\"restDay\":\"Fri, Sun\"}', '::1', 'Abaredes, Malaya was added.', 'OK', 0, '2026-05-14 01:24:20'),
(148, 4, 'Test Admin', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 6, NULL, '{\"id\":\"6\",\"employeeNo\":\"KPFH-C080\",\"employeeName\":\"Abaredes, Malaya\",\"department\":\"Nursing\",\"shift\":\"Morning\",\"shiftTime\":\"07:00 AM - 03:00 PM\",\"days\":[\"Mon\",\"Tue\",\"Wed\",\"Thu\",\"Sat\"],\"effectiveDate\":\"2026-05-18\",\"endDate\":\"2026-05-23\",\"restDay\":\"Fri, Sun\"}', '::1', 'Abaredes, Malaya was added.', 'OK', 0, '2026-05-14 01:43:40'),
(149, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-14 07:53:14'),
(150, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-14 07:53:20'),
(151, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-14 07:53:20'),
(152, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-14 07:57:43'),
(153, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-14 07:57:54'),
(154, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-14 07:57:54'),
(155, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-14 08:16:19'),
(156, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-14 08:16:19'),
(157, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-14 08:29:19'),
(158, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-14 08:29:47'),
(159, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-15 00:25:23'),
(160, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-15 00:25:23'),
(161, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-15 00:25:30'),
(162, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-15 00:25:38'),
(163, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-15 00:25:38'),
(164, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-15 00:25:46'),
(165, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-15 00:26:14'),
(166, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-15 00:26:14'),
(167, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-15 00:27:05'),
(168, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-15 00:27:05'),
(169, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-15 00:48:36'),
(170, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-15 00:48:48'),
(171, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-15 00:48:48'),
(172, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-15 01:10:33'),
(173, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-15 01:10:33'),
(174, 1, 'Super Admin', 'Signatory Updated', 'UPDATE', 'Signatory', 'signatories', 5, '0', '{\"id\":\"5\",\"name\":\"Thea Villanueva\",\"position\":\"HR Clerk II\",\"role\":\"DTR Processor\",\"department\":\"Human Resources\",\"order\":5,\"active\":false}', '::1', 'Thea Villanueva was updated.', 'OK', 0, '2026-05-15 01:16:09'),
(175, 1, 'Super Admin', 'Signatory Updated', 'UPDATE', 'Signatory', 'signatories', 5, '0', '{\"id\":\"5\",\"name\":\"Thea Villanueva\",\"position\":\"HR Clerk II\",\"role\":\"DTR Processor\",\"department\":\"Human Resources\",\"order\":5,\"active\":true}', '::1', 'Thea Villanueva was updated.', 'OK', 0, '2026-05-15 01:16:16'),
(176, 4, 'Test Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged out.', 'OK', 0, '2026-05-15 01:31:49'),
(177, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-15 01:31:58'),
(178, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-15 01:31:58'),
(179, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 6, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"lastName\":\"Agrimano\",\"firstName\":\"Rheanbelle \",\"middleName\":\"C.\",\"position\":\"Administrative Aide III\",\"department\":\"Information Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"\",\"birthDate\":\"2002-05-31\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":6}', '::1', 'Agrimano, Rheanbelle  was updated.', 'OK', 0, '2026-05-15 01:33:16'),
(180, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Agrimano, Rheanbelle  updated.', 'OK', 0, '2026-05-15 01:33:16'),
(181, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 6, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"lastName\":\"Agrimano\",\"firstName\":\"Rheanbelle \",\"middleName\":\"C.\",\"position\":\"Administrative Aide III\",\"department\":\"Information Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"\",\"birthDate\":\"2002-05-30\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":6}', '::1', 'Agrimano, Rheanbelle  was updated.', 'OK', 0, '2026-05-15 01:33:44'),
(182, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Agrimano, Rheanbelle  updated.', 'OK', 0, '2026-05-15 01:33:44'),
(183, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-15 01:37:30'),
(184, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-15 01:37:41'),
(185, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-15 01:37:41'),
(186, 4, 'Test Admin', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 3, NULL, '{\"id\":\"3\",\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle\",\"department\":\"Information Technology\",\"shift\":\"Morning\",\"shiftTime\":\"07:00 AM - 03:00 PM\",\"days\":[\"Mon\",\"Tue\",\"Wed\",\"Thu\",\"Sun\"],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"Fri, Sat\"}', '::1', 'Agrimano, Rheanbelle was added.', 'OK', 0, '2026-05-15 01:52:51'),
(187, 4, 'Test Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged out.', 'OK', 0, '2026-05-15 02:51:09'),
(188, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-15 02:51:38'),
(189, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-15 02:51:38'),
(190, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-15 04:15:48'),
(191, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-15 04:40:27'),
(192, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-15 04:51:16'),
(193, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-15 04:53:23'),
(194, 1, 'Super Admin', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 6, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"lastName\":\"Agrimano\",\"firstName\":\"Rheanbelle mae marie\",\"middleName\":\"C.\",\"position\":\"Administrative Aide III\",\"department\":\"Information Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"\",\"birthDate\":\"2002-05-30\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":6}', '::1', 'Agrimano, Rheanbelle mae marie was updated.', 'OK', 0, '2026-05-15 05:22:42'),
(195, 1, 'Super Admin', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Agrimano, Rheanbelle mae marie updated.', 'OK', 0, '2026-05-15 05:22:42'),
(196, 1, 'Super Admin', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Agrimano, Rheanbelle  updated.', 'OK', 0, '2026-05-15 05:25:10'),
(197, 1, 'Super Admin', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 6, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"lastName\":\"Agrimano\",\"firstName\":\"Rheanbelle \",\"middleName\":\"C.\",\"position\":\"Administrative Aide III\",\"department\":\"Information Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"\",\"birthDate\":\"2002-05-30\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":6}', '::1', 'Agrimano, Rheanbelle  was updated.', 'OK', 0, '2026-05-15 05:25:10'),
(198, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-15 06:39:17'),
(199, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-15 06:39:17'),
(200, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-15 06:39:28'),
(201, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-15 06:39:38'),
(202, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-15 06:39:38'),
(203, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-15 07:07:49'),
(204, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-15 07:07:49'),
(205, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 3, NULL, '{\"id\":\"3\",\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle\",\"department\":\"Information Technology\",\"shift\":\"Morning\",\"shiftTime\":\"07:00 AM - 03:00 PM\",\"days\":[\"Mon\",\"Tue\",\"Wed\",\"Thu\",\"Sun\"],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"Fri, Sat\"}', '::1', 'Agrimano, Rheanbelle was added.', 'OK', 0, '2026-05-15 07:35:13'),
(206, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-16 01:21:40'),
(207, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-16 01:21:40'),
(208, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 269, NULL, '{\"employeeNo\":\"KPFH-C080\",\"lastName\":\"Abarede\",\"firstName\":\"Malaya\",\"middleName\":\"A.\",\"position\":\"Nursing Attendant I\",\"department\":\"Nursing\",\"employmentStatus\":\"Casual\",\"dateHired\":\"2010-02-08\",\"birthDate\":\"\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":269}', '::1', 'Abarede, Malaya was updated.', 'OK', 0, '2026-05-16 01:48:07'),
(209, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Abarede, Malaya updated.', 'OK', 0, '2026-05-16 01:48:07'),
(210, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 269, NULL, '{\"employeeNo\":\"KPFH-C080\",\"lastName\":\"Abaredes\",\"firstName\":\"Malaya\",\"middleName\":\"A.\",\"position\":\"Nursing Attendant I\",\"department\":\"Nursing\",\"employmentStatus\":\"Casual\",\"dateHired\":\"2010-02-08\",\"birthDate\":\"\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":269}', '::1', 'Abaredes, Malaya was updated.', 'OK', 0, '2026-05-16 01:48:44'),
(211, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Abaredes, Malaya updated.', 'OK', 0, '2026-05-16 01:48:44'),
(212, 3, 'DIOS User', 'Employee Added', 'CREATE', 'Employee', 'employees', 370, NULL, '{\"id\":\"370\",\"employeeNo\":\"1010\",\"lastName\":\"DIEZ\",\"firstName\":\"JOHN BENNETH\",\"middleName\":\"NAAGAS\",\"position\":\"Security Guard I\",\"designation\":\"\",\"department\":\"Information Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"1995-03-16\",\"birthDate\":\"2004-03-13\",\"age\":\"0\",\"gender\":\"Male\",\"civilStatus\":\"Widowed\",\"address\":\"TIMALAN NAIC CAVITE\",\"contactNo\":\"09121212121\",\"email\":\"johnbenneth12@gmail.com\",\"salary\":200000,\"sgStep\":\"ADMINISTRATIVE\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-16 02:29:45'),
(213, 3, 'DIOS User', 'Employee Added', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'New employee DIEZ, JOHN BENNETH added.', 'OK', 0, '2026-05-16 02:29:45'),
(214, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 370, NULL, '{\"employeeNo\":\"1010\",\"lastName\":\"DIEZ\",\"firstName\":\"JOHN BENNETH\",\"middleName\":\"NAAGAS\",\"position\":\"Security Guard I\",\"department\":\"Information Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"1995-03-16\",\"birthDate\":\"2004-05-28\",\"gender\":\"Male\",\"civilStatus\":\"Widowed\",\"address\":\"TIMALAN NAIC CAVITE\",\"contactNo\":\"09121212121\",\"email\":\"johnbenneth12@gmail.com\",\"salary\":200000,\"sgStep\":\"ADMINISTRATIVE\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":370}', '::1', 'DIEZ, JOHN BENNETH was updated.', 'OK', 0, '2026-05-16 02:31:35'),
(215, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee DIEZ, JOHN BENNETH updated.', 'OK', 0, '2026-05-16 02:31:35'),
(216, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 10, NULL, '{\"id\":\"10\",\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"shift\":\"Morning\",\"shiftTime\":\"07:00 AM - 03:00 PM\",\"days\":[\"Mon\",\"Tue\",\"Wed\",\"Thu\",\"Fri\",\"Sat\"],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"Sun\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-16 02:33:50'),
(217, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 10, NULL, '{\"id\":\"10\",\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"shift\":\"Morning\",\"shiftTime\":\"07:00 AM - 03:00 PM\",\"days\":[\"Mon\",\"Tue\",\"Wed\",\"Thu\",\"Fri\",\"Sat\"],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"Sun\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-16 02:34:39'),
(218, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-16 03:58:22'),
(219, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-16 03:59:02'),
(220, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-16 03:59:02'),
(221, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-16 04:03:57'),
(222, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-16 04:05:26');
INSERT INTO `audit_logs` (`id`, `user_id`, `user_name`, `action`, `action_type`, `module`, `affected_table`, `record_id`, `old_values`, `new_values`, `ip_address`, `details`, `status`, `archived`, `created_at`) VALUES
(223, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-16 04:05:27'),
(224, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-16 04:07:36'),
(225, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-16 04:07:36'),
(226, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-16 05:38:54'),
(227, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-16 05:38:54'),
(228, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-16 05:39:17'),
(229, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-16 05:39:17'),
(230, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 7 deactivated.', 'OK', 0, '2026-05-16 05:39:57'),
(231, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 6 deactivated.', 'OK', 0, '2026-05-16 05:40:00'),
(232, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 5 deactivated.', 'OK', 0, '2026-05-16 05:40:03'),
(233, 3, 'DIOS User', 'Sign Up', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'New user Admin (admin@1) registered.', 'OK', 0, '2026-05-16 05:41:03'),
(234, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 11 deactivated.', 'OK', 0, '2026-05-16 05:45:54'),
(235, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 7 deactivated.', 'OK', 0, '2026-05-16 05:45:58'),
(236, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 6 deactivated.', 'OK', 0, '2026-05-16 05:46:02'),
(237, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 5 deactivated.', 'OK', 0, '2026-05-16 05:46:06'),
(238, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 11 deactivated.', 'OK', 0, '2026-05-16 05:51:38'),
(239, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 7 deactivated.', 'OK', 0, '2026-05-16 05:51:41'),
(240, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 6 deactivated.', 'OK', 0, '2026-05-16 05:51:46'),
(241, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 5 deactivated.', 'OK', 0, '2026-05-16 05:51:53'),
(242, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 5 deactivated.', 'OK', 0, '2026-05-16 05:54:48'),
(243, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 6 deactivated.', 'OK', 0, '2026-05-16 05:54:51'),
(244, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 7 deactivated.', 'OK', 0, '2026-05-16 05:54:54'),
(245, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 11 deactivated.', 'OK', 0, '2026-05-16 05:55:41'),
(246, 3, 'DIOS User', 'Sign Up', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'New user Admin (admin1) registered.', 'OK', 0, '2026-05-16 05:56:15'),
(247, 12, 'Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Admin logged in.', 'OK', 0, '2026-05-16 05:56:32'),
(248, 12, 'Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Admin logged in.', 'OK', 0, '2026-05-16 05:56:32'),
(249, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-16 05:57:14'),
(250, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-16 05:57:14'),
(251, 2, 'HR Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'HR Admin logged in.', 'OK', 0, '2026-05-16 06:14:51'),
(252, 2, 'HR Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'HR Admin logged in.', 'OK', 0, '2026-05-16 06:14:51'),
(253, 2, 'Test Personnel Userhr', 'Profile Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Personnel Userhr updated their profile.', 'OK', 0, '2026-05-16 06:15:52'),
(254, 2, 'Test Personnel User', 'Profile Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Personnel User updated their profile.', 'OK', 0, '2026-05-16 06:16:04'),
(255, 4, 'Test Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged out.', 'OK', 0, '2026-05-16 06:29:10'),
(256, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-16 06:29:18'),
(257, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-16 06:29:18'),
(258, 4, 'Test Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged out.', 'OK', 0, '2026-05-16 06:29:23'),
(259, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-16 06:38:41'),
(260, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-16 06:38:41'),
(261, 2, 'Test Personnel User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Personnel User logged in.', 'OK', 0, '2026-05-16 06:39:24'),
(262, 2, 'Test Personnel User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Personnel User logged in.', 'OK', 0, '2026-05-16 06:39:24'),
(263, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-16 06:39:55'),
(264, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-16 06:39:55'),
(265, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-16 08:04:44'),
(266, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-16 08:04:44'),
(267, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-17 16:15:33'),
(268, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-17 16:15:33'),
(269, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-17 16:16:10'),
(270, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-17 16:16:11'),
(271, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-18 01:32:26'),
(272, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-18 01:32:26'),
(273, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-18 01:33:00'),
(274, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-18 01:33:00'),
(275, 1, 'Super Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged out.', 'OK', 0, '2026-05-18 01:33:08'),
(276, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-18 01:35:52'),
(277, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-18 01:35:52'),
(278, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-18 02:40:29'),
(279, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-18 02:40:29'),
(280, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-18 03:10:19'),
(281, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-18 03:10:32'),
(282, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-18 03:10:32'),
(283, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-18 03:35:34'),
(284, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-18 03:35:34'),
(285, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-18 03:39:32'),
(286, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-18 03:39:32'),
(287, 2, 'Test Personnel User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Personnel User logged in.', 'OK', 0, '2026-05-18 03:44:02'),
(288, 2, 'Test Personnel User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Personnel User logged in.', 'OK', 0, '2026-05-18 03:44:02'),
(289, 2, 'Test Personnel User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Personnel User logged in.', 'OK', 0, '2026-05-18 05:45:37'),
(290, 2, 'Test Personnel User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Personnel User logged in.', 'OK', 0, '2026-05-18 05:45:37'),
(291, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-18 05:55:54'),
(292, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-18 05:55:54'),
(293, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-18 05:56:08'),
(294, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-18 05:56:08'),
(295, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-18 05:56:25'),
(296, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-18 05:56:25'),
(297, 2, 'Test Personnel User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Personnel User logged in.', 'OK', 0, '2026-05-18 05:57:01'),
(298, 2, 'Test Personnel User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Personnel User logged in.', 'OK', 0, '2026-05-18 05:57:01'),
(299, 12, 'Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Admin logged in.', 'OK', 0, '2026-05-18 06:00:00'),
(300, 12, 'Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Admin logged in.', 'OK', 0, '2026-05-18 06:00:00'),
(301, 1, 'Super Admin', 'Employee Added', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'New employee Consunji, Shawn Mico added.', 'OK', 0, '2026-05-18 06:07:33'),
(302, 1, 'Super Admin', 'Employee Added', 'CREATE', 'Employee', 'employees', 371, NULL, '{\"id\":\"371\",\"employeeNo\":\"GEAMH-111\",\"lastName\":\"Consunji\",\"firstName\":\"Shawn Mico\",\"middleName\":\"\",\"position\":\"\",\"designation\":\"\",\"department\":\"\",\"employmentStatus\":\"Permanent\",\"dateHired\":\"\",\"birthDate\":\"2026-05-31\",\"age\":\"0\",\"gender\":\"Male\",\"civilStatus\":\"Separated\",\"address\":\"De Ocampo, TMC\",\"contactNo\":\"09090909090\",\"email\":\"shawn@geamh.gov.ph\",\"salary\":0,\"sgStep\":\"\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true}', '::1', 'Consunji, Shawn Mico was added.', 'OK', 0, '2026-05-18 06:07:33'),
(303, 1, 'Super Admin', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 371, NULL, '{\"employeeNo\":\"GEAMH-111\",\"lastName\":\"Consunji\",\"firstName\":\"Shawn Mico\",\"middleName\":\"\",\"position\":\"\",\"department\":\"\",\"employmentStatus\":\"Permanent\",\"dateHired\":\"\",\"birthDate\":\"1999-05-31\",\"gender\":\"Male\",\"civilStatus\":\"Separated\",\"address\":\"De Ocampo, TMC\",\"contactNo\":\"09090909090\",\"email\":\"shawn@geamh.gov.ph\",\"salary\":0,\"sgStep\":\"\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":371}', '::1', 'Consunji, Shawn Mico was updated.', 'OK', 0, '2026-05-18 06:08:25'),
(304, 1, 'Super Admin', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Consunji, Shawn Mico updated.', 'OK', 0, '2026-05-18 06:08:25'),
(305, 12, 'Admin', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 6, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"lastName\":\"Agrimano\",\"firstName\":\"Rheanbelle \",\"middleName\":\"C.\",\"position\":\"Administrative Aide III\",\"department\":\"Information Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"\",\"birthDate\":\"2002-05-30\",\"gender\":\"Female\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":6}', '::1', 'Agrimano, Rheanbelle  was updated.', 'OK', 0, '2026-05-18 06:23:57'),
(306, 12, 'Admin', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Agrimano, Rheanbelle  updated.', 'OK', 0, '2026-05-18 06:23:57'),
(307, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', NULL, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"startTime\":\"05:00\",\"endTime\":\"17:00\",\"remarks\":\"test\",\"dates\":[\"2026-04-30\",\"2026-05-01\",\"2026-05-02\",\"2026-05-03\",\"2026-05-04\"],\"count\":5}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-18 07:55:06'),
(308, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-18 08:21:55'),
(309, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-18 08:21:55'),
(310, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 23, NULL, '{\"id\":\"23\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-09\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:33:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-18 08:33:54'),
(311, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 23, NULL, '{\"id\":\"23\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-09\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:33:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-18 08:33:54'),
(312, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 23, NULL, '{\"id\":\"23\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-09\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:33:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-18 08:33:54'),
(313, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 23, NULL, '{\"id\":\"23\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-09\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:33:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-18 08:33:54'),
(314, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 23, NULL, '{\"id\":\"23\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-09\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:33:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-18 08:33:54'),
(315, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-18 08:35:46'),
(316, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-18 08:35:46'),
(317, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 37, NULL, '{\"id\":\"37\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-15\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(318, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 37, NULL, '{\"id\":\"37\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-15\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(319, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 37, NULL, '{\"id\":\"37\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-15\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(320, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 37, NULL, '{\"id\":\"37\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-15\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(321, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 37, NULL, '{\"id\":\"37\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-15\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(322, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 39, NULL, '{\"id\":\"39\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-16\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(323, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 39, NULL, '{\"id\":\"39\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-16\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(324, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 37, NULL, '{\"id\":\"37\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-15\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(325, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 37, NULL, '{\"id\":\"37\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-15\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(326, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 37, NULL, '{\"id\":\"37\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-15\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(327, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 39, NULL, '{\"id\":\"39\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-16\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(328, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 39, NULL, '{\"id\":\"39\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-16\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(329, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 39, NULL, '{\"id\":\"39\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-16\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(330, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 39, NULL, '{\"id\":\"39\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-16\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(331, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 39, NULL, '{\"id\":\"39\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-16\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(332, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 39, NULL, '{\"id\":\"39\",\"employeeId\":null,\"employeeNo\":\"KPFH-C078\",\"employeeName\":\"Lugay, Herbert\",\"department\":\"Administrative\",\"scheduleDate\":\"2026-05-16\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:38:14\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Lugay, Herbert was added.', 'OK', 0, '2026-05-18 08:38:14'),
(333, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 44, NULL, '{\"id\":\"44\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-06\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"210\",\"shiftName\":\"Evening\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:46:38\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-18 08:46:38'),
(334, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 44, NULL, '{\"id\":\"44\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-06\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"210\",\"shiftName\":\"Evening\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:46:38\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-18 08:46:38'),
(335, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 44, NULL, '{\"id\":\"44\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-06\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"210\",\"shiftName\":\"Evening\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:46:38\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-18 08:46:38'),
(336, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 44, NULL, '{\"id\":\"44\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-06\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"210\",\"shiftName\":\"Evening\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:46:38\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-18 08:46:38'),
(337, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 44, NULL, '{\"id\":\"44\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-06\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"210\",\"shiftName\":\"Evening\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:46:38\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-18 08:46:38'),
(338, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 44, NULL, '{\"id\":\"44\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-06\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"210\",\"shiftName\":\"Evening\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:46:38\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-18 08:46:38'),
(339, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 44, NULL, '{\"id\":\"44\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-06\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"210\",\"shiftName\":\"Evening\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-18 16:46:38\",\"remarks\":\"\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-18 08:46:38'),
(340, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-19 00:34:38'),
(341, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-19 00:34:38'),
(342, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-19 00:39:29'),
(343, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-19 00:39:29'),
(344, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-19 01:01:35'),
(345, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-19 01:01:35'),
(346, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-19 02:05:04'),
(347, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-19 02:05:04'),
(348, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-19 02:21:26'),
(349, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-19 02:21:26'),
(350, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 53, NULL, '{\"id\":\"53\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:24\",\"remarks\":\"Test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 02:25:24'),
(351, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 53, NULL, '{\"id\":\"53\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:24\",\"remarks\":\"Test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 02:25:24'),
(352, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 53, NULL, '{\"id\":\"53\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:24\",\"remarks\":\"Test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 02:25:24'),
(353, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 53, NULL, '{\"id\":\"53\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:24\",\"remarks\":\"Test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 02:25:24'),
(354, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 53, NULL, '{\"id\":\"53\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:24\",\"remarks\":\"Test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 02:25:24'),
(355, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 53, NULL, '{\"id\":\"53\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:24\",\"remarks\":\"Test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 02:25:24'),
(356, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 53, NULL, '{\"id\":\"53\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:24\",\"remarks\":\"Test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 02:25:24'),
(357, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 53, NULL, '{\"id\":\"53\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:24\",\"remarks\":\"Test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 02:25:24'),
(358, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 53, NULL, '{\"id\":\"53\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:24\",\"remarks\":\"Test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 02:25:24'),
(359, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 53, NULL, '{\"id\":\"53\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:24\",\"remarks\":\"Test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 02:25:24'),
(360, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 53, NULL, '{\"id\":\"53\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:24\",\"remarks\":\"Test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 02:25:24'),
(361, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 53, NULL, '{\"id\":\"53\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:24\",\"remarks\":\"Test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 02:25:24'),
(362, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(363, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(364, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(365, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(366, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(367, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(368, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(369, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(370, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(371, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(372, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(373, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54');
INSERT INTO `audit_logs` (`id`, `user_id`, `user_name`, `action`, `action_type`, `module`, `affected_table`, `record_id`, `old_values`, `new_values`, `ip_address`, `details`, `status`, `archived`, `created_at`) VALUES
(374, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(375, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(376, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(377, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(378, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(379, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(380, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(381, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(382, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(383, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(384, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(385, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(386, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(387, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(388, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(389, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(390, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(391, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(392, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 88, NULL, '{\"id\":\"88\",\"employeeId\":null,\"employeeNo\":\"1010\",\"employeeName\":\"DIEZ, JOHN BENNETH\",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:25:54\",\"remarks\":\"test sched\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'DIEZ, JOHN BENNETH was added.', 'OK', 0, '2026-05-19 02:25:54'),
(393, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(394, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(395, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(396, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(397, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(398, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(399, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(400, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(401, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(402, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(403, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(404, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(405, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(406, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(407, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(408, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(409, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(410, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(411, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(412, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(413, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(414, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(415, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(416, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(417, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(418, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(419, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(420, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(421, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(422, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(423, 3, 'DIOS User', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 118, NULL, '{\"id\":\"118\",\"employeeId\":null,\"employeeNo\":\"KPFH-C081\",\"employeeName\":\"Agner, Analyn\",\"department\":\"Nursing\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 10:38:06\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agner, Analyn was added.', 'OK', 0, '2026-05-19 02:38:06'),
(424, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-19 03:14:19'),
(425, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-19 03:14:19'),
(426, 3, 'DIOS User', 'Sign Up', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'New user Lugay, Herbert (imis@admin) registered.', 'OK', 0, '2026-05-19 03:22:12'),
(427, 4, 'Test Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged out.', 'OK', 0, '2026-05-19 03:22:33'),
(428, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 03:22:42'),
(429, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 03:22:42'),
(430, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-19 05:26:14'),
(431, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-19 05:26:14'),
(432, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-19 05:27:14'),
(433, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-19 05:27:14'),
(434, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-19 05:27:39'),
(435, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-19 05:27:39'),
(436, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 05:29:58'),
(437, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 05:29:58'),
(438, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 05:38:08'),
(439, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 05:38:08'),
(440, 3, 'DIOS User', 'User Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User Lugay, Herbert updated.', 'OK', 0, '2026-05-19 05:50:38'),
(441, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-19 05:51:15'),
(442, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-19 05:51:15'),
(443, 4, 'Test Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged out.', 'OK', 0, '2026-05-19 05:51:23'),
(444, 3, 'DIOS User', 'User Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User Lugay, Herbert updated.', 'OK', 0, '2026-05-19 06:02:05'),
(445, 3, 'DIOS User', 'User Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User Lugay, Herbert updated.', 'OK', 0, '2026-05-19 06:10:26'),
(446, 13, 'Lugay, Herbert', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged out.', 'OK', 0, '2026-05-19 06:10:33'),
(447, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 06:10:44'),
(448, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 06:10:44'),
(449, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-19 06:13:12'),
(450, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-19 06:13:12'),
(451, 1, 'Super Admin', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 6, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"lastName\":\"Agrimano\",\"firstName\":\"Rheanbelle \",\"middleName\":\"C.\",\"position\":\"Administrative Aide III\",\"department\":\"Informatiion Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"\",\"birthDate\":\"2002-05-30\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":6}', '::1', 'Agrimano, Rheanbelle  was updated.', 'OK', 0, '2026-05-19 06:13:52'),
(452, 1, 'Super Admin', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Agrimano, Rheanbelle  updated.', 'OK', 0, '2026-05-19 06:13:52'),
(453, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 370, NULL, '{\"employeeNo\":\"1010\",\"lastName\":\"DIEZ\",\"firstName\":\"JOHN BENNETH\",\"middleName\":\"NAAGAS\",\"position\":\"Security Guard I\",\"department\":\"Information Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"1995-03-16\",\"birthDate\":\"2004-05-28\",\"gender\":\"\",\"civilStatus\":\"Widowed\",\"address\":\"TIMALAN NAIC CAVITE\",\"contactNo\":\"09121212121\",\"email\":\"johnbenneth12@gmail.com\",\"salary\":200000,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":370}', '::1', 'DIEZ, JOHN BENNETH was updated.', 'OK', 0, '2026-05-19 06:35:42'),
(454, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee DIEZ, JOHN BENNETH updated.', 'OK', 0, '2026-05-19 06:35:42'),
(455, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Agrimano, Rheanbelle  updated.', 'OK', 0, '2026-05-19 06:55:10'),
(456, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 6, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"lastName\":\"Agrimano\",\"firstName\":\"Rheanbelle \",\"middleName\":\"C.\",\"position\":\"Administrative Aide III\",\"department\":\"Information Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"\",\"birthDate\":\"2002-05-30\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":6}', '::1', 'Agrimano, Rheanbelle  was updated.', 'OK', 0, '2026-05-19 06:55:10'),
(457, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 06:56:43'),
(458, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 06:56:43'),
(459, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 121, NULL, '{\"id\":\"121\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-01\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(460, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 122, NULL, '{\"id\":\"122\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-02\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(461, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 123, NULL, '{\"id\":\"123\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-03\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(462, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 124, NULL, '{\"id\":\"124\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-04\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(463, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 125, NULL, '{\"id\":\"125\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-05\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(464, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 126, NULL, '{\"id\":\"126\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-06\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(465, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 127, NULL, '{\"id\":\"127\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-07\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(466, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 128, NULL, '{\"id\":\"128\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-08\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(467, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 129, NULL, '{\"id\":\"129\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-09\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(468, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 130, NULL, '{\"id\":\"130\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-10\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(469, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 131, NULL, '{\"id\":\"131\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-11\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(470, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 132, NULL, '{\"id\":\"132\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-12\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(471, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 133, NULL, '{\"id\":\"133\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-13\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(472, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 134, NULL, '{\"id\":\"134\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-14\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(473, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 135, NULL, '{\"id\":\"135\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-15\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(474, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 136, NULL, '{\"id\":\"136\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-16\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02');
INSERT INTO `audit_logs` (`id`, `user_id`, `user_name`, `action`, `action_type`, `module`, `affected_table`, `record_id`, `old_values`, `new_values`, `ip_address`, `details`, `status`, `archived`, `created_at`) VALUES
(475, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 137, NULL, '{\"id\":\"137\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-17\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(476, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 138, NULL, '{\"id\":\"138\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-18\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(477, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 139, NULL, '{\"id\":\"139\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-19\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(478, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 140, NULL, '{\"id\":\"140\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-20\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(479, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 141, NULL, '{\"id\":\"141\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-21\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:02'),
(480, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 143, NULL, '{\"id\":\"143\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-23\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:03\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:03'),
(481, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 142, NULL, '{\"id\":\"142\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-22\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"OFF\",\"shiftName\":\"Off Duty\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:02\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:03'),
(482, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 144, NULL, '{\"id\":\"144\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-24\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:03\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:03'),
(483, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 145, NULL, '{\"id\":\"145\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-25\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:03\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:03'),
(484, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 146, NULL, '{\"id\":\"146\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-26\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:03\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:03'),
(485, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 147, NULL, '{\"id\":\"147\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-28\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:03\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:03'),
(486, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 147, NULL, '{\"id\":\"147\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-28\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:03\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:03'),
(487, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 149, NULL, '{\"id\":\"149\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-29\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:03\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:03'),
(488, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 150, NULL, '{\"id\":\"150\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-30\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:03\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:03'),
(489, 13, 'Lugay, Herbert', 'Schedule Added', 'CREATE', 'Schedule', 'schedules', 151, NULL, '{\"id\":\"151\",\"employeeId\":null,\"employeeNo\":\"GEAMH-C001\",\"employeeName\":\"Agrimano, Rheanbelle \",\"department\":\"Information Technology\",\"scheduleDate\":\"2026-05-31\",\"startTime\":\"08:00:00\",\"endTime\":\"17:00:00\",\"shiftCode\":\"85\",\"shiftName\":\"Standard\",\"status\":\"Pending\",\"submittedDate\":null,\"lastUpdated\":\"2026-05-19 14:59:03\",\"remarks\":\"test\",\"shift\":\"Morning\",\"shiftTime\":\"\",\"days\":[],\"effectiveDate\":\"\",\"endDate\":\"\",\"restDay\":\"\"}', '::1', 'Agrimano, Rheanbelle  was added.', 'OK', 0, '2026-05-19 06:59:03'),
(490, 13, 'Lugay, Herbert', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged out.', 'OK', 0, '2026-05-19 07:07:47'),
(491, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 07:07:54'),
(492, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 07:07:54'),
(493, 13, 'Lugay, Herbert', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged out.', 'OK', 0, '2026-05-19 07:14:35'),
(494, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 07:14:45'),
(495, 13, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 07:14:45'),
(496, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-19 07:15:27'),
(497, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-19 07:15:27'),
(498, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 13 deactivated.', 'OK', 0, '2026-05-19 07:15:51'),
(499, 3, 'DIOS User', 'Sign Up', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'New user Lugay, Herbert (imis@admin) registered.', 'OK', 0, '2026-05-19 07:16:26'),
(500, 4, 'Test Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged out.', 'OK', 0, '2026-05-19 07:16:33'),
(501, 14, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 07:16:40'),
(502, 14, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 07:16:40'),
(503, 14, 'Lugay, Herbert', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged out.', 'OK', 0, '2026-05-19 07:20:35'),
(504, 14, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 07:20:44'),
(505, 14, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 07:20:44'),
(506, 14, 'Lugay, Herbert', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged out.', 'OK', 0, '2026-05-19 07:21:15'),
(507, 3, 'DIOS User', 'User Deleted', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User ID 14 deactivated.', 'OK', 0, '2026-05-19 07:21:40'),
(508, 3, 'DIOS User', 'Sign Up', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'New user Lugay, Herbert (imis@admin) registered.', 'OK', 0, '2026-05-19 07:23:24'),
(509, 3, 'DIOS User', 'User Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User Lugay, Herbert updated.', 'OK', 0, '2026-05-19 07:23:33'),
(510, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 07:23:52'),
(511, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 07:23:52'),
(512, 3, 'DIOS User', 'User Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'User Lugay, Herbert updated.', 'OK', 0, '2026-05-19 07:24:15'),
(513, 15, 'Lugay, Herbert', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged out.', 'OK', 0, '2026-05-19 07:24:26'),
(514, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 07:24:37'),
(515, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-19 07:24:37'),
(516, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-19 08:00:32'),
(517, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-19 08:00:32'),
(518, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-19 08:02:38'),
(519, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-19 08:02:38'),
(520, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-20 00:42:03'),
(521, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-20 00:42:03'),
(522, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-20 00:46:32'),
(523, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-20 00:46:32'),
(524, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-20 05:31:58'),
(525, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-20 05:31:59'),
(526, 3, 'DIOS User', 'Profile Updated', 'OTHER', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User updated their profile.', 'OK', 0, '2026-05-20 06:28:40'),
(527, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-20 06:36:43'),
(528, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-20 07:11:33'),
(529, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-20 07:11:33'),
(530, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-21 00:27:24'),
(531, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-21 00:27:24'),
(532, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-21 00:31:55'),
(533, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-21 00:31:55'),
(534, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-21 04:35:05'),
(535, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-21 04:35:05'),
(536, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-21 07:52:04'),
(537, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-21 07:52:04'),
(538, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-22 00:20:43'),
(539, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-22 00:20:43'),
(540, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 269, NULL, '{\"employeeNo\":\"KPFH-C080\",\"lastName\":\"Abaredes\",\"firstName\":\"Malaya\",\"middleName\":\"A.\",\"position\":\"Nursing Attendant I\",\"department\":\"Nursing\",\"employmentStatus\":\"Casual\",\"dateHired\":\"2010-02-08\",\"birthDate\":\"20001-05-21\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":269}', '::1', 'Abaredes, Malaya was updated.', 'OK', 0, '2026-05-22 00:40:05'),
(541, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Abaredes, Malaya updated.', 'OK', 0, '2026-05-22 00:40:05'),
(542, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-22 00:41:40'),
(543, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-22 00:41:40'),
(544, 3, 'DIOS User', 'Employee Updated', 'UPDATE', 'Employee', 'employees', 6, NULL, '{\"employeeNo\":\"GEAMH-C001\",\"lastName\":\"Agrimano\",\"firstName\":\"Rheanbelle \",\"middleName\":\"C.\",\"position\":\"Administrative Aide III\",\"department\":\"Information Technology\",\"employmentStatus\":\"Casual\",\"dateHired\":\"\",\"birthDate\":\"2002-05-21\",\"gender\":\"\",\"civilStatus\":\"\",\"address\":\"\",\"contactNo\":\"\",\"email\":\"\",\"salary\":0,\"sgStep\":\"0\",\"tin\":\"\",\"sss\":\"\",\"philhealth\":\"\",\"pagibig\":\"\",\"active\":true,\"designation\":\"\",\"id\":6}', '::1', 'Agrimano, Rheanbelle  was updated.', 'OK', 0, '2026-05-22 00:45:04'),
(545, 3, 'DIOS User', 'Employee Updated', 'OTHER', 'Employee', NULL, NULL, NULL, NULL, '::1', 'Employee Agrimano, Rheanbelle  updated.', 'OK', 0, '2026-05-22 00:45:04'),
(546, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-22 01:00:13'),
(547, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-22 01:00:13'),
(548, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-22 02:25:23'),
(549, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-22 02:25:24'),
(550, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-22 04:55:08'),
(551, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-22 04:55:08'),
(552, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-22 04:55:43'),
(553, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-22 04:55:50'),
(554, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-22 04:55:50'),
(555, 4, 'Test Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged out.', 'OK', 0, '2026-05-22 04:56:06'),
(556, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-22 04:56:14'),
(557, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-22 04:56:14'),
(558, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-25 05:48:01'),
(559, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-25 05:48:02'),
(560, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-25 06:19:52'),
(561, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-25 06:19:52'),
(562, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-25 06:20:37'),
(563, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-25 06:20:37'),
(564, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Admin logged in.', 'OK', 0, '2026-05-25 06:21:57'),
(565, 4, 'Test Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged in.', 'OK', 0, '2026-05-25 06:21:57'),
(566, 2, 'Test Personnel User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Test Personnel User logged in.', 'OK', 0, '2026-05-25 06:27:11'),
(567, 4, 'Test Admin', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Test Admin logged out.', 'OK', 0, '2026-05-25 06:37:49'),
(568, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-25 06:38:07'),
(569, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-25 06:38:07'),
(570, 12, 'Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Admin logged in.', 'OK', 0, '2026-05-25 06:38:48'),
(571, 12, 'Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Admin logged in.', 'OK', 0, '2026-05-25 06:38:48'),
(572, 12, 'Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Admin logged in.', 'OK', 0, '2026-05-25 07:11:55'),
(573, 12, 'Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Admin logged in.', 'OK', 0, '2026-05-25 07:11:55'),
(574, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-26 02:11:28'),
(575, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-26 02:11:28'),
(576, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-26 02:34:01'),
(577, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-26 02:34:01'),
(578, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-26 08:21:29'),
(579, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-26 08:21:29'),
(580, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-26 08:32:46'),
(581, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-26 08:32:46'),
(582, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-26 08:48:30'),
(583, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-26 08:48:30'),
(584, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-27 05:09:12'),
(585, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-27 05:09:12'),
(586, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-27 16:59:52'),
(587, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-27 16:59:52'),
(588, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-28 00:23:39'),
(589, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-28 00:23:39'),
(590, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-28 01:41:44'),
(591, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-28 01:41:44'),
(592, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-28 03:18:16'),
(593, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-28 03:18:16'),
(594, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-28 03:26:37'),
(595, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-28 03:26:43'),
(596, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-28 03:26:43'),
(597, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-28 05:40:16'),
(598, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-28 05:40:16'),
(599, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Super Admin logged in.', 'OK', 0, '2026-05-28 05:44:43'),
(600, 1, 'Super Admin', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Super Admin logged in.', 'OK', 0, '2026-05-28 05:44:43'),
(601, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-28 06:03:36'),
(602, 15, 'Lugay, Herbert', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged in.', 'OK', 0, '2026-05-28 06:03:36'),
(603, 15, 'Lugay, Herbert', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'Lugay, Herbert logged out.', 'OK', 0, '2026-05-28 06:09:58'),
(604, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-28 06:10:57'),
(605, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-28 06:10:57'),
(606, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, NULL, 'DIOS User logged in.', 'OK', 0, '2026-05-28 08:26:58'),
(607, 3, 'DIOS User', 'Login', 'LOGIN', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged in.', 'OK', 0, '2026-05-28 08:26:58'),
(608, 3, 'DIOS User', 'Logout', 'LOGOUT', 'Auth', NULL, NULL, NULL, NULL, '::1', 'DIOS User logged out.', 'OK', 0, '2026-05-28 08:27:54');

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `code` varchar(20) DEFAULT NULL COMMENT 'Short code e.g. NUR, MED',
  `description` varchar(255) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`id`, `name`, `code`, `description`, `active`, `created_at`, `updated_at`) VALUES
(26, 'KP-Dialysis Extension Clinic', 'KP-DIALYSIS', 'Korea-Philippines Friendship Hospital Dialysis Extension Clinic', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(27, 'GEAMH-Dialysis Extension Clinic', 'GEAMH-DIALYSIS', 'General Emilio Aguinaldo Memorial Hospital Dialysis Extension Clinic', 1, '2026-05-22 02:48:51', '2026-05-25 08:13:31'),
(28, 'KP-Laboratory', 'KP-LAB', 'Korea-Philippines Friendship Hospital Laboratory', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(29, 'GEAMH-Laboratory', 'GEAMH-LAB', 'General Emilio Aguinaldo Memorial Hospital Laboratory', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(30, 'KP-Maintenance', 'KP-MAINT', 'Korea-Philippines Friendship Hospital Maintenance', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(31, 'GEAMH-Maintenance', 'GEAMH-MAINT', 'General Emilio Aguinaldo Memorial Hospital Maintenance', 1, '2026-05-22 02:48:51', '2026-05-25 08:20:28'),
(32, 'KP-Medical Arts Building', 'KP-MAB', 'Korea-Philippines Friendship Hospital Medical Arts Building', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(33, 'GEAMH-Medical Arts Building', 'GEAMH-MAB', 'General Emilio Aguinaldo Memorial Hospital Medical Arts Building', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(34, 'KP-Nursing', 'KP-NURSING', 'Korea-Philippines Friendship Hospital Nursing', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(35, 'GEAMH-Nursing', 'GEAMH-NURSING', 'General Emilio Aguinaldo Memorial Hospital Nursing', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(36, 'KP-Pharmacy', 'KP-PHARM', 'Korea-Philippines Friendship Hospital Pharmacy', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(37, 'GEAMH-Pharmacy', 'GEAMH-PHARM', 'General Emilio Aguinaldo Memorial Hospital Pharmacy', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(38, 'KP-Radiology', 'KP-RADIO', 'Korea-Philippines Friendship Hospital Radiology', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(39, 'GEAMH-Radiology', 'GEAMH-RADIO', 'General Emilio Aguinaldo Memorial Hospital Radiology', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(40, 'KP-Rehabilitation', 'KP-REHAB', 'Korea-Philippines Friendship Hospital Rehabilitation', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(41, 'GEAMH-Rehabilitation', 'GEAMH-REHAB', 'General Emilio Aguinaldo Memorial Hospital Rehabilitation', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(42, 'KP-Social Work', 'KP-SOCIAL', 'Korea-Philippines Friendship Hospital Social Work', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51'),
(43, 'GEAMH-Social Work', 'GEAMH-SOCIAL', 'General Emilio Aguinaldo Memorial Hospital Social Work', 1, '2026-05-22 02:48:51', '2026-05-22 02:48:51');

-- --------------------------------------------------------

--
-- Table structure for table `document_tracking`
--

CREATE TABLE `document_tracking` (
  `id` int(10) UNSIGNED NOT NULL,
  `doc_type` enum('DTR Transmittal','Leave Form','Travel Order','Payroll Document','Memorandum','Other') NOT NULL DEFAULT 'DTR Transmittal',
  `doc_no` varchar(50) NOT NULL,
  `from_office` varchar(100) NOT NULL,
  `to_office` varchar(100) NOT NULL,
  `date_forwarded` date NOT NULL,
  `date_received` date DEFAULT NULL,
  `received_by` varchar(100) DEFAULT NULL,
  `status` enum('Pending','In Transit','Received','Returned','Lost') NOT NULL DEFAULT 'Pending',
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `direction` enum('incoming','outgoing') NOT NULL DEFAULT 'incoming',
  `route` varchar(255) DEFAULT NULL,
  `linked_outgoing_id` int(11) DEFAULT NULL,
  `cancelled` tinyint(1) DEFAULT 0,
  `cancel_reason` text DEFAULT NULL,
  `cancel_pulled_by` varchar(255) DEFAULT NULL,
  `cancel_care_off` varchar(255) DEFAULT NULL,
  `classification` varchar(50) DEFAULT 'Specific'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `document_tracking`
--

INSERT INTO `document_tracking` (`id`, `doc_type`, `doc_no`, `from_office`, `to_office`, `date_forwarded`, `date_received`, `received_by`, `status`, `remarks`, `created_at`, `updated_at`, `direction`, `route`, `linked_outgoing_id`, `cancelled`, `cancel_reason`, `cancel_pulled_by`, `cancel_care_off`, `classification`) VALUES
(1, 'Travel Order', '123', 'me', 'HR Office', '2026-05-11', '2026-05-11', 'Gonzales, Realyn P. (HR AMELA)', 'Received', '', '2026-05-11 02:39:16', '2026-05-11 02:42:51', 'incoming', NULL, NULL, 0, NULL, NULL, NULL, 'Specific'),
(2, 'DTR Transmittal', '76543', 'HR Office', 'jhgfd', '2026-05-11', NULL, NULL, '', '', '2026-05-11 03:18:25', '2026-05-11 03:18:25', 'incoming', NULL, NULL, 0, NULL, NULL, NULL, 'Specific');

-- --------------------------------------------------------

--
-- Table structure for table `dtr_history`
--

CREATE TABLE `dtr_history` (
  `id` int(10) UNSIGNED NOT NULL,
  `dtr_record_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to dtr_records (nullable after delete)',
  `employee_no` varchar(20) NOT NULL,
  `employee_name` varchar(150) NOT NULL,
  `period` varchar(50) NOT NULL,
  `transmittal_type` enum('Main','Thea','Other') NOT NULL DEFAULT 'Main',
  `action` varchar(60) NOT NULL COMMENT 'e.g. DTR Submitted, DTR Updated, DTR Deleted',
  `status` varchar(30) NOT NULL DEFAULT 'Pending',
  `remarks` text DEFAULT NULL,
  `processed_by` varchar(100) NOT NULL DEFAULT 'System',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dtr_history`
--

INSERT INTO `dtr_history` (`id`, `dtr_record_id`, `employee_no`, `employee_name`, `period`, `transmittal_type`, `action`, `status`, `remarks`, `processed_by`, `created_at`) VALUES
(1, 1, 'GEAMH-C001', 'Agrimano, Rheanbelle C.', 'April 1-15, 2026', 'Main', 'DTR Submitted', 'Submitted', 'oks sha', 'Super Admin', '2026-05-11 02:23:04');

-- --------------------------------------------------------

--
-- Table structure for table `dtr_records`
--

CREATE TABLE `dtr_records` (
  `id` int(10) UNSIGNED NOT NULL,
  `employee_id` int(10) UNSIGNED DEFAULT NULL,
  `employee_no` varchar(20) NOT NULL,
  `employee_name` varchar(150) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `period` varchar(50) NOT NULL COMMENT 'e.g. April 1-15, 2026',
  `transmittal_type` enum('Main','Thea','Other') NOT NULL DEFAULT 'Main',
  `submitted_by` varchar(100) DEFAULT NULL,
  `date_submitted` date DEFAULT NULL,
  `date_received` date DEFAULT NULL,
  `verified_by` varchar(100) DEFAULT NULL,
  `verification_date` date DEFAULT NULL,
  `status` enum('Pending','Submitted','Received','Verified','Returned') NOT NULL DEFAULT 'Pending',
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dtr_records`
--

INSERT INTO `dtr_records` (`id`, `employee_id`, `employee_no`, `employee_name`, `department`, `period`, `transmittal_type`, `submitted_by`, `date_submitted`, `date_received`, `verified_by`, `verification_date`, `status`, `remarks`, `created_at`, `updated_at`) VALUES
(1, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle C.', 'Information Technology', 'April 1-15, 2026', 'Main', 'basta', '2026-05-11', '2026-05-11', 'basta', '2026-05-11', 'Submitted', 'oks sha', '2026-05-11 02:23:04', '2026-05-11 02:23:04');

-- --------------------------------------------------------

--
-- Table structure for table `dtr_signatories`
--

CREATE TABLE `dtr_signatories` (
  `id` int(10) UNSIGNED NOT NULL,
  `dtr_id` int(10) UNSIGNED NOT NULL,
  `signatory_id` int(10) UNSIGNED NOT NULL,
  `signed` tinyint(1) NOT NULL DEFAULT 0,
  `signed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE `employees` (
  `id` int(10) UNSIGNED NOT NULL,
  `employee_no` varchar(20) NOT NULL COMMENT 'e.g. GEAMH-001',
  `last_name` varchar(60) NOT NULL,
  `first_name` varchar(60) NOT NULL,
  `middle_name` varchar(60) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `designation` varchar(100) DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `employment_status` enum('Permanent','Casual','Contractual','Job Order','Co-terminus') NOT NULL DEFAULT 'Casual',
  `date_hired` date DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `age` tinyint(3) UNSIGNED DEFAULT NULL,
  `gender` enum('Male','Female','') DEFAULT '',
  `civil_status` enum('Single','Married','Widowed','Separated','') DEFAULT '',
  `address` varchar(255) DEFAULT NULL,
  `contact_no` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `salary` decimal(12,2) NOT NULL DEFAULT 0.00,
  `sg_step` varchar(20) DEFAULT NULL COMMENT 'Salary Grade / Step',
  `tin_number` varchar(20) DEFAULT NULL,
  `sss_gsis_number` varchar(25) DEFAULT NULL,
  `phil_number` varchar(25) DEFAULT NULL COMMENT 'PhilHealth number',
  `pi_number` varchar(25) DEFAULT NULL COMMENT 'Pag-IBIG number',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employees`
--

INSERT INTO `employees` (`id`, `employee_no`, `last_name`, `first_name`, `middle_name`, `position`, `designation`, `department`, `employment_status`, `date_hired`, `birth_date`, `age`, `gender`, `civil_status`, `address`, `contact_no`, `email`, `salary`, `sg_step`, `tin_number`, `sss_gsis_number`, `phil_number`, `pi_number`, `active`, `created_at`, `updated_at`) VALUES
(5, 'geamh-909', 'Ladua', 'Hesed', 'mark', '', '', '', 'Permanent', NULL, '1961-04-12', 0, '', 'Single', '', '', '', '0.00', '0', '', '', '', '', 1, '2026-04-24 01:52:04', '2026-04-28 01:39:54'),
(6, 'GEAMH-C001', 'Agrimano', 'Rheanbelle ', 'C.', 'Administrative Aide III', '', 'KP-Maintenance', 'Casual', NULL, '2002-05-21', 0, '', '', '', '', '', '0.00', '0', '', '', '', '', 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(7, 'GEAMH-C002', 'Alcazar', 'Lesly Ann', 'P.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(8, 'GEAMH-C003', 'Almanzor', 'Kristel Jane', 'V.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(9, 'GEAMH-C004', 'Alvarez', 'Mariane Xyril', 'F.', 'Administrative Aide III', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(10, 'GEAMH-C005', 'Amurao', 'Chelsea', 'B.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(11, 'GEAMH-C006', 'Apostol', 'April Mae', '', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(12, 'GEAMH-C007', 'Aquiatan', 'Grace', 'A.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(13, 'GEAMH-C008', 'Arroyo', 'Mercy', 'C.', 'Social Welfare Assistant', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(14, 'GEAMH-C009', 'Asas', 'Lee Leigh', 'T.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(15, 'GEAMH-C010', 'Asas', 'Naira Jane', 'V.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(16, 'GEAMH-C011', 'Atas', 'Noel', 'M.', 'Administrative Aide I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(17, 'GEAMH-C012', 'Atijera', 'Edelyne Mae', 'B.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(18, 'GEAMH-C013', 'Aure', 'Chrystal Joice', 'B.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(19, 'GEAMH-C014', 'Austria', 'Airish', 'M.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(20, 'GEAMH-C015', 'Ayo', 'Marilyn', 'A.', 'Administrative Aide III', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(21, 'GEAMH-C016', 'Azarcon', 'Madelaine', 'V.', 'Pharmacist I', NULL, 'KP-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(22, 'GEAMH-C017', 'Bacsal', 'Feena', 'D.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(23, 'GEAMH-C018', 'Badian', 'Jaycelle', 'S.', 'Administrative Aide I', NULL, 'KP-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(24, 'GEAMH-C019', 'Baladiang', 'Harold Jason', 'D.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(25, 'GEAMH-C020', 'Bale', 'Lylamie', 'R.', 'Administrative Aide I', NULL, 'GEAMH-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(26, 'GEAMH-C021', 'Balita', 'Edwin', 'S.', 'Administrative Aide III', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(27, 'GEAMH-C022', 'Bay', 'Michael', 'L.', 'Administrative Aide I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(28, 'GEAMH-C023', 'Bersamina', 'Aebrille', 'C.', 'Administrative Aide I', NULL, 'KP-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(29, 'GEAMH-C024', 'Billones', 'Lady Anne', 'P.', 'Medical Technologist I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(30, 'GEAMH-C025', 'Bondal', 'Arvin', 'S.', 'Administrative Aide I', NULL, 'GEAMH-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(31, 'GEAMH-C026', 'Buendia', 'Pamela', 'T.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(32, 'GEAMH-C027', 'Bueno', 'Marion Joy', 'A.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(33, 'GEAMH-C028', 'Buhain', 'Madonna', 'T.', 'Administrative Aide III', NULL, 'KP-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(34, 'GEAMH-C029', 'Buhay', 'Hazel Ann', 'D.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(35, 'GEAMH-C030', 'Buid', 'Ronnel', 'V.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(36, 'GEAMH-C031', 'Caacbay', 'Rodelynne', 'E.', 'Pharmacist I', NULL, 'GEAMH-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(37, 'GEAMH-C032', 'Camarinta', 'Caryl', 'C.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(38, 'GEAMH-C033', 'Cayanan', 'Abigail', 'E.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(39, 'GEAMH-C034', 'Cayao', 'Ella Marie', 'M.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(40, 'GEAMH-C035', 'Cayao', 'Emerson', 'C.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(41, 'GEAMH-C036', 'Caymo', 'Myranhel', 'B.', 'Administrative Aide I', NULL, 'GEAMH-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(42, 'GEAMH-C037', 'Cervantes', 'Julienne Mirano', '', 'Pharmacist I', NULL, 'KP-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(43, 'GEAMH-C038', 'Comia', 'Irish', 'A.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(44, 'GEAMH-C039', 'Corral', 'Jennylyn', 'V.', 'Administrative Aide IV', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(45, 'GEAMH-C040', 'Costa', 'Marilyn', 'C.', 'Administrative Aide III', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(46, 'GEAMH-C041', 'Costelo', 'Reggie', 'C.', 'Administrative Aide I', NULL, 'KP-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(47, 'GEAMH-C042', 'Cresido', 'Veronica', 'P.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(48, 'GEAMH-C043', 'Cresino', 'Mark Jay', 'R.', 'Administrative Aide I', NULL, 'GEAMH-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(49, 'GEAMH-C044', 'Crizaldo', 'Jonathan', 'C.', 'Administrative Aide IV', NULL, 'KP-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(50, 'GEAMH-C045', 'Cubillo', 'Ma. Fatima', 'P.', 'Administrative Aide I', NULL, 'GEAMH-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(51, 'GEAMH-C046', 'Cueno', 'Haven Kyle', 'C.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(52, 'GEAMH-C047', 'Dabanda', 'Rosemarie', 'R.', 'Administrative Aide IV', NULL, 'KP-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(53, 'GEAMH-C048', 'Dalisay', 'Chris Lester', 'C.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(54, 'GEAMH-C049', 'Dalisay', 'Fatima Joy', 'P.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(55, 'GEAMH-C050', 'De Borja', 'Verna Fe', 'M.', 'Administrative Aide III', NULL, 'GEAMH-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(56, 'GEAMH-C051', 'De Castro', 'ShaiNa', 'T.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(57, 'GEAMH-C052', 'De Castro', 'ShaiRa', 'T.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(58, 'GEAMH-C053', 'De Lara', 'Mary Christine', 'C.', 'Administrative Aide III', NULL, 'KP-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(59, 'GEAMH-C054', 'De San Jose', 'Harlene', 'H.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(60, 'GEAMH-C055', 'De Vera', 'Joylyn', 'Z.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(61, 'GEAMH-C056', 'Decillo', 'Nida', 'J.', 'Administrative Aide I', NULL, 'GEAMH-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(62, 'GEAMH-C057', 'Dela Cruz', 'Maida', '', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(63, 'GEAMH-C058', 'Dela Cruz', 'Yvette', 'R.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(64, 'GEAMH-C059', 'Dela Pena', 'Wenilyn', 'M.', 'Physical Therapist I', NULL, 'KP-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(65, 'GEAMH-C060', 'Delfin', 'Norman Vincent', 'R.', 'Physical Therapist I', NULL, 'GEAMH-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(66, 'GEAMH-C061', 'Delos Reyes', 'Kathy', 'M.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(67, 'GEAMH-C062', 'Delovino', 'Nadine', 'H.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(68, 'GEAMH-C063', 'Denosta', 'Genilyn', 'P.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(69, 'GEAMH-C064', 'Dilig', 'Imelda', 'R.', 'Administrative Aide I', NULL, 'KP-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(70, 'GEAMH-C065', 'Dimapilis', 'Jake Kirby', 'L.', 'Pharmacist I', NULL, 'GEAMH-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(71, 'GEAMH-C066', 'Dinglasan', 'Maribel', 'R.', 'Administrative Aide I', NULL, 'GEAMH-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(72, 'GEAMH-C067', 'Dolz', 'Camille', 'D.', 'Administrative Aide III', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(73, 'GEAMH-C068', 'Dumagat', 'Vernadeth', 'B.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(74, 'GEAMH-C069', 'Elicierto', 'Joan Michelle', 'L.', 'Administrative Aide I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(75, 'GEAMH-C070', 'Eseque', 'Princess Joy', 'R.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(76, 'GEAMH-C071', 'Espiritu', 'Rowena', 'F.', 'Administrative Aide IV', NULL, 'KP-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(77, 'GEAMH-C072', 'Estacio', 'Jennifer Mae Hayes', '', 'Medical Technologist I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(78, 'GEAMH-C073', 'Fabre', 'Elaine', 'C.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(79, 'GEAMH-C074', 'Fabro', 'Ma. Jumeline', 'A.', 'Medical Technologist I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(80, 'GEAMH-C075', 'Fello', 'Rencel Roan', 'C.', 'Administrative Aide III', NULL, 'GEAMH-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(81, 'GEAMH-C076', 'Feranil', 'Helbert', 'L.', 'Administrative Aide I', NULL, 'KP-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(82, 'GEAMH-C077', 'Flores', 'Celerina', 'T.', 'Administrative Aide I', NULL, 'GEAMH-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(83, 'GEAMH-C078', 'Flores', 'Eidle Wise', 'B.', 'Administrative Aide III', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(84, 'GEAMH-C079', 'Flores', 'Gigi', 'F.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(85, 'GEAMH-C080', 'Flores', 'Maria Patrisha Nicole', '', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(86, 'GEAMH-C081', 'Flores', 'Reynaldo', 'B.', 'Administrative Aide I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(87, 'GEAMH-C082', 'Fuaso', 'Joelee Larise Allen', 'L.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(88, 'GEAMH-C083', 'Gallego', 'Joan Heyniel', 'A.', 'Medical Technologist I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(89, 'GEAMH-C084', 'Garcia', 'Lyra Gemma', 'M.', 'Administrative Aide I', NULL, 'KP-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(90, 'GEAMH-C085', 'Golfo', 'Janelle', 'P.', 'Administrative Aide I', NULL, 'GEAMH-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(91, 'GEAMH-C086', 'Gonzales', 'Arjay', 'Y.', 'Administrative Aide I', NULL, 'KP-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(92, 'GEAMH-C087', 'Gonzales', 'Daniel', 'P.', 'Administrative Aide I', NULL, 'GEAMH-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(93, 'GEAMH-C088', 'Gonzales', 'Lloyd', 'E.', 'Administrative Aide IV', NULL, 'KP-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(94, 'GEAMH-C089', 'Gonzales', 'Tonette Bray', '', 'Physical Therapist I', NULL, 'KP-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(95, 'GEAMH-C090', 'Guinto', 'Elvira', 'V.', 'Administrative Aide I', NULL, 'GEAMH-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(96, 'GEAMH-C091', 'Hernandez', 'Angelo Jehn Eidref', 'S.', 'Medical Technologist I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(97, 'GEAMH-C092', 'Hernandez', 'Donato', 'Q.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(98, 'GEAMH-C093', 'Hernandez', 'Gabriel Kein', 'G.', 'Physical Therapist I', NULL, 'GEAMH-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(99, 'GEAMH-C094', 'Hernandez', 'Vanessa', 'B.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(100, 'GEAMH-C095', 'Herrera', 'Ethel Joy', 'G.', 'Administrative Aide IV', NULL, 'KP-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(101, 'GEAMH-C096', 'Honrada', 'Rosafe', 'G.', 'Administrative Aide III', NULL, 'GEAMH-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(102, 'GEAMH-C097', 'Janolo', 'Russel Christian', 'E.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(103, 'GEAMH-C098', 'Jeciel', 'Daniel Vhince', 'M.', 'Administrative Aide I', NULL, 'KP-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(104, 'GEAMH-C099', 'Junsay', 'Maria Menchie Loria', '', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(105, 'GEAMH-C100', 'Juson', 'Agnes Sanico', '', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(106, 'GEAMH-C101', 'Lascano', 'Elrish Laine', 'G.', 'Administrative Aide I', NULL, 'GEAMH-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(107, 'GEAMH-C102', 'Laure', 'Romeo Jr.', 'P.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(108, 'GEAMH-C103', 'Lavador', 'Edrize', 'A.', 'Social Welfare Assistant', NULL, 'KP-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(109, 'GEAMH-C104', 'Levita', 'Hariett Marian Ros', 'T.', 'Administrative Aide I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(110, 'GEAMH-C105', 'Limbo', 'Edwin', 'P.', 'Administrative Aide I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(111, 'GEAMH-C106', 'Lizardo', 'Jessica', 'B.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(112, 'GEAMH-C107', 'Macantan', 'Catherine', 'B.', 'Administrative Aide III', NULL, 'KP-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(113, 'GEAMH-C108', 'Maderazo', 'Kim Gellyssa', 'D.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(114, 'GEAMH-C109', 'Magayam', 'Cleo Mae', 'B.', 'Medical Technologist I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(115, 'GEAMH-C110', 'Malabanan', 'Jake Rojan', 'E.', 'Administrative Aide I', NULL, 'GEAMH-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(116, 'GEAMH-C111', 'Mendoza', 'Elionor Vargas', '', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(117, 'GEAMH-C112', 'Merca', 'Menerissa', 'R.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(118, 'GEAMH-C113', 'Mercado', 'Marnie Marie', 'B.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(119, 'GEAMH-C114', 'Moico', 'Princess May', 'P.', 'Administrative Aide III', NULL, 'KP-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(120, 'GEAMH-C115', 'Mojica', 'Michelle', 'A.', 'Administrative Aide I', NULL, 'GEAMH-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(121, 'GEAMH-C116', 'Monton', 'Patrick', 'L.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(122, 'GEAMH-C117', 'Morada', 'Rowena Irish', 'A.', 'Administrative Aide III', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(123, 'GEAMH-C118', 'Murata', 'Rolf Nico', 'M.', 'Physical Therapist I', NULL, 'KP-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(124, 'GEAMH-C119', 'Nicomedes', 'Ma. Cristina', 'M.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(125, 'GEAMH-C120', 'Niviar', 'Mark Carlo', 'A.', 'Medical Technologist I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(126, 'GEAMH-C121', 'Nocidal', 'Henry', 'V.', 'Administrative Aide I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(127, 'GEAMH-C122', 'Noel', 'Joanna Kristin', 'A.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(128, 'GEAMH-C123', 'Nuestro', 'Princess', 'R.', 'Social Welfare Assistant', NULL, 'GEAMH-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(129, 'GEAMH-C124', 'Nueva', 'Jesusa', 'S.', 'Medical Technologist I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(130, 'GEAMH-C125', 'Nueva', 'Kimberly Rose', 'B.', 'Administrative Aide I', NULL, 'KP-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(131, 'GEAMH-C126', 'Nueva', 'Tyrone', 'P.', 'Administrative Aide I', NULL, 'GEAMH-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(132, 'GEAMH-C127', 'Pabalate', 'Digna', 'P.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(133, 'GEAMH-C128', 'Pacete', 'Cay Enriquez', '', 'Pharmacist I', NULL, 'KP-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(134, 'GEAMH-C129', 'Palmario', 'Prescila', 'G.', 'Administrative Aide IV', NULL, 'KP-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(135, 'GEAMH-C130', 'Panganiban', 'Alfie', 'I.', 'Administrative Aide I', NULL, 'GEAMH-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(136, 'GEAMH-C131', 'Pejana', 'Roxanne', 'R.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(137, 'GEAMH-C132', 'Pendon', 'Alvin', 'R.', 'Administrative Aide I', NULL, 'KP-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:58'),
(138, 'GEAMH-C133', 'Penus', 'Maeka Penalba', '', 'Administrative Aide III', NULL, 'GEAMH-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(139, 'GEAMH-C134', 'Perena', 'Gina', 'E.', 'Physical Therapist I', NULL, 'GEAMH-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(140, 'GEAMH-C135', 'Perena', 'Karen Louise', 'M.', 'Administrative Aide I', NULL, 'KP-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(141, 'GEAMH-C136', 'Perin', 'Emma', 'R.', 'Administrative Aide I', NULL, 'GEAMH-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(142, 'GEAMH-C137', 'Pinazo', 'Katelyne', 'S.', 'Radiologic Technologist I', NULL, 'KP-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(143, 'GEAMH-C138', 'Poblete', 'Sheila Marie', 'P.', 'Administrative Aide III', NULL, 'KP-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(144, 'GEAMH-C139', 'Puedan', 'Jenivic', 'E.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(145, 'GEAMH-C140', 'Punilas', 'Maria Beatriz', 'E.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(146, 'GEAMH-C141', 'Quijano', 'Renante', 'L.', 'Administrative Aide I', NULL, 'GEAMH-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(147, 'GEAMH-C142', 'Quirap', 'Marvin', 'S.', 'Administrative Aide I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(148, 'GEAMH-C143', 'Rabanzo', 'Abegail', 'P.', 'Medical Technologist I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(149, 'GEAMH-C144', 'Ramirez', 'Devy', '', 'Administrative Aide I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(150, 'GEAMH-C145', 'Ramos', 'Rosita', 'D.', 'Administrative Aide I', NULL, 'KP-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(151, 'GEAMH-C146', 'Reyes', 'Clariza', 'B.', 'Administrative Aide III', NULL, 'GEAMH-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(152, 'GEAMH-C147', 'Reyes', 'Irish Mae Nabata', '', 'Administrative Aide I', NULL, 'KP-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(153, 'GEAMH-C148', 'Reyes', 'Maria Rhea', 'A.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(154, 'GEAMH-C149', 'Riego De Dios', 'Triccia Anne', 'M.', 'Medical Technologist I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(155, 'GEAMH-C150', 'Rizo', 'Eddie Jr.', 'M.', 'Administrative Aide I', NULL, 'GEAMH-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(156, 'GEAMH-C151', 'Rodil', 'Bernard', 'A.', 'Administrative Aide I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(157, 'GEAMH-C152', 'Rodil', 'Nicca', 'I.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(158, 'GEAMH-C153', 'Rom', 'Merly', 'C.', 'Administrative Aide I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(159, 'GEAMH-C154', 'Romanes', 'Maybeljoy', 'C.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(160, 'GEAMH-C155', 'Salas', 'Ryza', 'G.', 'Medical Technologist I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(161, 'GEAMH-C156', 'Salgado', 'Jay', 'R.', 'Administrative Aide I', NULL, 'KP-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(162, 'GEAMH-C157', 'Saliedo', 'Richard', 'S.', 'Administrative Aide I', NULL, 'GEAMH-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(163, 'GEAMH-C158', 'Salvio', 'Melissa Joy', 'B.', 'Physical Therapist I', NULL, 'KP-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(164, 'GEAMH-C159', 'Sanchez', 'Jaypee', 'H.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(165, 'GEAMH-C160', 'Santander', 'Ace', '', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(166, 'GEAMH-C161', 'Santos', 'Marjorie', 'G.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(167, 'GEAMH-C162', 'Secreto', 'Vilma', 'G.', 'Administrative Aide III', NULL, 'KP-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(168, 'GEAMH-C163', 'Serrano', 'Ereca Jayomana', '', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(169, 'GEAMH-C164', 'Sibucao', 'Ma. Victoria', 'A.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(170, 'GEAMH-C165', 'Sierra', 'Ara Mina', 'M.', 'Medical Technologist I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(171, 'GEAMH-C166', 'Signo', 'Lorie Antonette', 'D.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(172, 'GEAMH-C167', 'Simbahan', 'Lovely Lyl-Ann Sierra', '', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(173, 'GEAMH-C168', 'Socito', 'Kristel', 'E.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(174, 'GEAMH-C169', 'Sol', 'Christian Rafael', 'S.', 'Physical Therapist I', NULL, 'GEAMH-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(175, 'GEAMH-C170', 'Solis', 'Mylin', 'G.', 'Administrative Aide I', NULL, 'GEAMH-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(176, 'GEAMH-C171', 'Tafalla', 'Jess Jason', 'P.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(177, 'GEAMH-C172', 'Tagustos', 'Carizza Krisell', 'B.', 'Medical Technologist I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(178, 'GEAMH-C173', 'Tuazon', 'Emma', 'C.', 'Administrative Aide I', NULL, 'KP-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(179, 'GEAMH-C174', 'Valerio', 'Christianne Jane', 'L.', 'Administrative Aide I', NULL, 'GEAMH-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(180, 'GEAMH-C175', 'Viadoy', 'Concepcion', 'A.', 'Administrative Aide I', NULL, 'KP-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(181, 'GEAMH-C176', 'Vicedo', 'Flordeliza', 'A.', 'Administrative Aide III', NULL, 'GEAMH-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(182, 'GEAMH-C177', 'Vicedo', 'Jhanine', 'P.', 'Administrative Aide I', NULL, 'KP-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(183, 'GEAMH-C178', 'Vidallo', 'Upracio Jr.', 'A.', 'Administrative Aide I', NULL, 'GEAMH-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(184, 'GEAMH-C179', 'Villanueva', 'Ma Criselda', 'D.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(185, 'GEAMH-C180', 'Volante', 'Mary Avigail', 'A.', 'Administrative Aide I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(186, 'GEAMH-C181', 'Aure', 'Kevin', 'R.', 'Nurse I', NULL, 'KP-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(187, 'GEAMH-C182', 'Acak', 'Rodelin Cabalfin', '', 'Administrative Aide I', NULL, 'GEAMH-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(188, 'GEAMH-C183', 'Gatdula', 'Gat Rolliezen', '', 'Nurse I', NULL, 'KP-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(189, 'GEAMH-C184', 'Rollan', 'Darvin', '', 'Administrative Aide I', NULL, 'GEAMH-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(190, 'KPFH-C001', 'Amparo', 'Rhoy', 'V.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(191, 'KPFH-C002', 'Amutan', 'Eunicaella', 'A.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(192, 'KPFH-C003', 'And', 'Daisy', 'Y.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(193, 'KPFH-C004', 'Anglo', 'Ian Rodel', 'B.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(194, 'KPFH-C005', 'Anglo', 'Joshua Christine', 'M.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(195, 'KPFH-C006', 'Asas', 'Mark Anthony', 'V.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(196, 'KPFH-C007', 'Baldoza', 'Jules Ashley', 'S.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(197, 'KPFH-C008', 'Bansales', 'Ma. Carmela', 'V.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(198, 'KPFH-C009', 'Belardo', 'Ailene Grace', 'F.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(199, 'KPFH-C010', 'Belleza', 'Maria Eden', 'C.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(200, 'KPFH-C011', 'Buale', 'Hazel', 'A.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(201, 'KPFH-C012', 'Bulatao', 'Sharon', 'B.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(202, 'KPFH-C013', 'Cabintoy', 'Clark', 'P.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(203, 'KPFH-C014', 'Cabrera', 'Andrew Louie', 'G.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(204, 'KPFH-C015', 'Calimutan', 'Girby Joe', 'C.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(205, 'KPFH-C016', 'Causaren', 'Jennilyn', 'C.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(206, 'KPFH-C017', 'Costa', 'Honeylyn', 'C.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(207, 'KPFH-C018', 'David', 'Rachel Anne', 'A.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(208, 'KPFH-C019', 'Denauto', 'Christine Angela', 'C.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(209, 'KPFH-C020', 'Ebojo', 'Stephanie Claire', 'B.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(210, 'KPFH-C021', 'Ersando', 'Diane Michelle', 'D.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(211, 'KPFH-C022', 'Escalante', 'Karen', 'P.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(212, 'KPFH-C023', 'Escano', 'Kith', 'E.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(213, 'KPFH-C024', 'Escober', 'Allianna Marie', 'P.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(214, 'KPFH-C025', 'Ganac', 'Sheen', 'S.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(215, 'KPFH-C026', 'Garcia', 'Juaymah', 'R.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(216, 'KPFH-C027', 'Glean', 'Jenelyn De Taza', '', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(217, 'KPFH-C028', 'Irinco', 'Geraldine', 'R.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28');
INSERT INTO `employees` (`id`, `employee_no`, `last_name`, `first_name`, `middle_name`, `position`, `designation`, `department`, `employment_status`, `date_hired`, `birth_date`, `age`, `gender`, `civil_status`, `address`, `contact_no`, `email`, `salary`, `sg_step`, `tin_number`, `sss_gsis_number`, `phil_number`, `pi_number`, `active`, `created_at`, `updated_at`) VALUES
(218, 'KPFH-C029', 'Jeciel', 'Jaypee', 'R.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(219, 'KPFH-C030', 'Limbitco', 'Louisa May', 'H.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(220, 'KPFH-C031', 'Madrid', 'Simon Archival', 'G.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(221, 'KPFH-C032', 'Malimban', 'Melba', 'O.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(222, 'KPFH-C033', 'Marges', 'Ma. Jamie', 'V.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(223, 'KPFH-C034', 'Nigoza', 'Marriah Realiesa Jayd', 'D.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(224, 'KPFH-C035', 'Orina', 'Joverlyn', 'B.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(225, 'KPFH-C036', 'Oriza', 'Joylene', 'R.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(226, 'KPFH-C037', 'Penalba', 'Kimberly', 'M.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(227, 'KPFH-C038', 'Perez', 'Jenelyn', 'A.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(228, 'KPFH-C039', 'Periodico', 'Aubrey Alliana', 'T.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(229, 'KPFH-C040', 'Perlado', 'Arish', 'R.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(230, 'KPFH-C041', 'Poniente', 'Jhay-Arr', 'L.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(231, 'KPFH-C042', 'Robles', 'Viktor Nigel', 'F.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(232, 'KPFH-C043', 'Rovillos', 'Joyce Ann', 'M.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(233, 'KPFH-C044', 'Sangalang', 'Mary Justinne', 'T.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(234, 'KPFH-C045', 'Singson', 'Louie Glenn', 'J.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(235, 'KPFH-C046', 'Soriano', 'Sherlie', 'S.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(236, 'KPFH-C047', 'Sortijas', 'Jacqueline', 'J.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(237, 'KPFH-C048', 'Sortijas', 'Leo Ray', 'P.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(238, 'KPFH-C049', 'Sumagui', 'Liezeth', 'P.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(239, 'KPFH-C050', 'Talay', 'Elaiza Mae', 'L.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(240, 'KPFH-C051', 'Tandoc', 'April Rose', 'D.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(241, 'KPFH-C052', 'Tapawan', 'Ansherina', 'A.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(242, 'KPFH-C053', 'Toledo', 'Kaizen Jay', 'R.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(243, 'KPFH-C054', 'Tupas', 'Alpha', 'M.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(244, 'KPFH-C055', 'Uy', 'Jasha Asshi', 'E.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(245, 'KPFH-C056', 'Asas', 'Monette', 'V.', 'Nurse I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(246, 'KPFH-C057', 'Salazar', 'Sofhia Bianca', 'B.', 'Nurse I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(247, 'KPFH-C058', 'Bataller', 'Christian Angelo', 'A.', 'Medical Technologist I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(248, 'KPFH-C059', 'Briones', 'Maria Reinalyn', 'V.', 'Medical Technologist I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(249, 'KPFH-C060', 'Capillo', 'Bethel Joy', 'C.', 'Medical Technologist I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(250, 'KPFH-C061', 'Creencia', 'Japie Chester', 'M.', 'Medical Technologist I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(251, 'KPFH-C062', 'Libiran', 'Marie Keicelyn', 'R.', 'Medical Technologist I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(252, 'KPFH-C063', 'Liveta', 'Camella', 'L.', 'Medical Technologist I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(253, 'KPFH-C064', 'Poblete', 'Suzaine', 'R.', 'Medical Technologist I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(254, 'KPFH-C065', 'Ramirez', 'Michelle', 'S.', 'Medical Technologist I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(255, 'KPFH-C066', 'Embudo', 'April Anne', 'S.', 'Pharmacist I', NULL, 'GEAMH-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(256, 'KPFH-C067', 'Fojas', 'Gail Allyson', 'M.', 'Pharmacist I', NULL, 'KP-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(257, 'KPFH-C068', 'Mendoza', 'Luisa', 'T.', 'Pharmacist I', NULL, 'GEAMH-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(258, 'KPFH-C069', 'Gan', 'Valerie', 'A.', 'Radiologic Technologist I', NULL, 'GEAMH-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(259, 'KPFH-C070', 'Estilloso', 'Marvy Jay', 'V.', 'Radiologic Technologist I', NULL, 'KP-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(260, 'KPFH-C071', 'Jose', 'Resilyn', 'S.', 'Radiologic Technologist I', NULL, 'GEAMH-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(261, 'KPFH-C072', 'Manuel', 'Monica', 'T.', 'Radiologic Technologist I', NULL, 'KP-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(262, 'KPFH-C073', 'Pascua', 'Marissa', 'U.', 'Radiologic Technologist I', NULL, 'GEAMH-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(263, 'KPFH-C074', 'Sarmiento', 'John Rae', 'R.', 'Radiologic Technologist I', NULL, 'KP-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(264, 'KPFH-C075', 'Bawalan', 'Jerico Noelle', 'A.', 'Radiologic Technologist I', NULL, 'GEAMH-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(265, 'KPFH-C076', 'Colorado', 'Rhodora', 'R.', 'Social Welfare Assistant', NULL, 'KP-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(266, 'KPFH-C077', 'Ortez', 'Albert Bryan', 'P.', 'Administrative Aide IV', NULL, 'KP-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(267, 'KPFH-C078', 'Lugay', 'Herbert', 'C.', 'Computer Operator II', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(268, 'KPFH-C079', 'Bates', 'July', 'A.', 'Computer Operator I', NULL, 'KP-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(269, 'KPFH-C080', 'Abaredes', 'Malaya', 'A.', 'Nursing Attendant I', '', 'KP-Nursing', 'Casual', '2010-02-08', '0000-00-00', 0, '', '', '', '', '', '0.00', '0', '', '', '', '', 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(270, 'KPFH-C081', 'Agner', 'Analyn', 'P.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(271, 'KPFH-C082', 'Alviz', 'Hilda', 'C.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(272, 'KPFH-C083', 'Ampon', 'Lalota', 'O.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(273, 'KPFH-C084', 'Babaan', 'Ma. Ronnamae', '', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(274, 'KPFH-C085', 'Brucal', 'Rodielyn', 'M.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(275, 'KPFH-C086', 'Buclatin', 'Dairiegold', 'S.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(276, 'KPFH-C087', 'Dariagan', 'Chyda', 'D.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(277, 'KPFH-C088', 'Ersando', 'Vivian', 'S.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(278, 'KPFH-C089', 'Escosia', 'Lea', 'D.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(279, 'KPFH-C090', 'Espanola', 'Asuncion', 'N.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(280, 'KPFH-C091', 'Isaias', 'Nenita', 'R.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(281, 'KPFH-C092', 'Lachica', 'Marites', 'U.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(282, 'KPFH-C093', 'Laroa', 'Patrick', 'S.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(283, 'KPFH-C094', 'Leonor', 'Michellenie', 'M.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(284, 'KPFH-C095', 'Limare', 'Kindly', 'V.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(285, 'KPFH-C096', 'Lubigan', 'Jasmin', 'D.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(286, 'KPFH-C097', 'Mabuti', 'Jerrybel', 'L.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(287, 'KPFH-C098', 'Manalo', 'Jaramie', 'E.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(288, 'KPFH-C099', 'Mangalinao', 'Khrisha Mhel', 'L.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(289, 'KPFH-C100', 'Marquez', 'Charina', 'C.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(290, 'KPFH-C101', 'Matiag', 'Loida', 'E.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(291, 'KPFH-C102', 'Mendoza', 'Melinda', 'S.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(292, 'KPFH-C103', 'Oli', 'Rachel', 'L.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(293, 'KPFH-C104', 'Parco', 'Jecelito', 'S.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(294, 'KPFH-C105', 'Pocua', 'Jude', 'J.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(295, 'KPFH-C106', 'Ramirez', 'Sherry Rose', 'N.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(296, 'KPFH-C107', 'Rementas', 'Celzie Anne', 'M.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(297, 'KPFH-C108', 'Roguel', 'Rosemarie', 'S.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(298, 'KPFH-C109', 'Romero', 'Maribel', 'M.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(299, 'KPFH-C110', 'Saligumba', 'Jovelyn', 'S.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(300, 'KPFH-C111', 'Sangalang', 'Marjorie', 'O.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(301, 'KPFH-C112', 'Sierra', 'Ferdinand Nimroh Noah', '', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(302, 'KPFH-C113', 'Tan', 'Quennie', 'U.', 'Nursing Attendant I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(303, 'KPFH-C114', 'Vicedo', 'Marlene', 'B.', 'Nursing Attendant I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(304, 'KPFH-C115', 'Andam', 'Lionel Carlo', 'P.', 'Administrative Aide I', NULL, 'GEAMH-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(305, 'KPFH-C116', 'Asas', 'Joselito', 'C.', 'Administrative Aide I', NULL, 'KP-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(306, 'KPFH-C117', 'Aspecto', 'Rosemarie', 'R.', 'Administrative Aide I', NULL, 'GEAMH-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(307, 'KPFH-C118', 'Avinante', 'Russel Bryell', 'E.', 'Administrative Aide I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(308, 'KPFH-C119', 'Baclayo', 'April Joy', 'G.', 'Administrative Aide I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(309, 'KPFH-C120', 'Bencito', 'Christopher', 'A.', 'Administrative Aide I', NULL, 'KP-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(310, 'KPFH-C121', 'Calitis', 'Diana', 'D.', 'Administrative Aide I', NULL, 'GEAMH-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(311, 'KPFH-C122', 'Carza', 'Ferdinand', 'C.', 'Administrative Aide I', NULL, 'KP-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(312, 'KPFH-C123', 'Cuesta', 'Ma. Cristina', 'V.', 'Administrative Aide I', NULL, 'GEAMH-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(313, 'KPFH-C124', 'Diloy', 'Gianne', 'D.', 'Administrative Aide I', NULL, 'KP-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(314, 'KPFH-C125', 'Ersando', 'Anna Patrisha', 'N.', 'Administrative Aide I', NULL, 'GEAMH-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(315, 'KPFH-C126', 'Feudo', 'Carol', 'F.', 'Administrative Aide I', NULL, 'KP-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(316, 'KPFH-C127', 'Lampadio', 'Rachelle', 'R.', 'Administrative Aide I', NULL, 'GEAMH-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(317, 'KPFH-C128', 'Lubigan', 'Jon Mariner', 'N.', 'Administrative Aide I', NULL, 'KP-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(318, 'KPFH-C129', 'Pagtalunan', 'Leonardo Jr.', 'B.', 'Administrative Aide I', NULL, 'GEAMH-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(319, 'KPFH-C130', 'Penus', 'Liezel', 'M.', 'Administrative Aide I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(320, 'KPFH-C131', 'Poniente', 'Maricris', 'L.', 'Administrative Aide I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(321, 'KPFH-C132', 'Romanes', 'Rico', 'C.', 'Administrative Aide I', NULL, 'KP-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(322, 'KPFH-C133', 'Torres', 'Joseph', 'G.', 'Administrative Aide I', NULL, 'GEAMH-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(323, 'KPFH-C134', 'Talagtag', 'Judith', 'M.', 'Administrative Aide I', NULL, 'KP-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(324, 'KPFH-C135', 'Alano', 'Jennifer', 'A.', 'Administrative Aide III', NULL, 'GEAMH-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(325, 'KPFH-C136', 'Andion', 'Amela Remia', 'V.', 'Administrative Aide III', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(326, 'KPFH-C137', 'Aribal', 'Raquel', 'L.', 'Administrative Aide III', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(327, 'KPFH-C138', 'Arzabal', 'Bernagrace', 'N.', 'Administrative Aide III', NULL, 'KP-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(328, 'KPFH-C139', 'Badian', 'Carlo', 'M.', 'Administrative Aide III', NULL, 'GEAMH-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(329, 'KPFH-C140', 'Bashan', 'Marjorie', 'S.', 'Administrative Aide III', NULL, 'KP-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(330, 'KPFH-C141', 'Baylon', 'Randy', 'B.', 'Administrative Aide III', NULL, 'GEAMH-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(331, 'KPFH-C142', 'Bermas', 'Monica', 'B.', 'Administrative Aide III', NULL, 'KP-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(332, 'KPFH-C143', 'Dela Cruz', 'Mary Grace', 'F.', 'Administrative Aide III', NULL, 'GEAMH-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(333, 'KPFH-C144', 'Dumadag', 'Emmie', 'I.', 'Administrative Aide III', NULL, 'KP-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(334, 'KPFH-C145', 'Galduen', 'Reingelbert', 'Z.', 'Administrative Aide III', NULL, 'GEAMH-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(335, 'KPFH-C146', 'Guevarra', 'Besinisa', 'M.', 'Administrative Aide III', NULL, 'KP-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(336, 'KPFH-C147', 'Hondo', 'Jennilyn', 'R.', 'Administrative Aide III', NULL, 'GEAMH-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(337, 'KPFH-C148', 'Jeciel', 'Jonathan', 'E.', 'Administrative Aide III', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(338, 'KPFH-C149', 'Marasigan', 'Mae Ann', 'A.', 'Administrative Aide III', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(339, 'KPFH-C150', 'Padua', 'Shariel Ann', 'S.', 'Administrative Aide III', NULL, 'KP-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(340, 'KPFH-C151', 'Penus', 'Eva', 'R.', 'Administrative Aide III', NULL, 'GEAMH-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(341, 'KPFH-C152', 'Rala', 'Lalaine', 'A.', 'Administrative Aide III', NULL, 'KP-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(342, 'KPFH-C153', 'Ramos', 'Jerson', 'J.', 'Administrative Aide III', NULL, 'GEAMH-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(343, 'KPFH-C154', 'Rom', 'Marineth', 'V.', 'Administrative Aide III', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(344, 'KPFH-C155', 'Roraldo', 'Jenievabes', 'D.', 'Administrative Aide III', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(345, 'KPFH-C156', 'Roxas', 'Michelle', 'P.', 'Administrative Aide III', NULL, 'KP-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(346, 'KPFH-C157', 'Sadava', 'Jesur Jr.', 'M.', 'Administrative Aide III', NULL, 'GEAMH-Pharmacy', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(347, 'KPFH-C158', 'Sallutan', 'Sherwin', 'R.', 'Administrative Aide III', NULL, 'KP-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(348, 'KPFH-C159', 'Tongson', 'Melver Ace', 'N.', 'Administrative Aide III', NULL, 'GEAMH-Radiology', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(349, 'KPFH-C160', 'Vivero', 'Daisy', 'R.', 'Administrative Aide III', NULL, 'KP-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(350, 'KPFH-C161', 'Baldestamon', 'Gina', 'D.', 'Administrative Aide II', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(351, 'KPFH-C162', 'Ignaco', 'Marry Grace', 'V.', 'Administrative Aide II', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 03:07:28'),
(352, 'KPFH-C163', 'Antonio', 'Larvie', 'H.', 'Administrative Aide I', NULL, 'GEAMH-Rehabilitation', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(353, 'KPFH-C164', 'Asas', 'Ayala', 'M.', 'Administrative Aide I', NULL, 'KP-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(354, 'KPFH-C165', 'Asas', 'King James R. II', '', 'Administrative Aide I', NULL, 'GEAMH-Social Work', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(355, 'KPFH-C166', 'Cantanero', 'Darwin', 'C.', 'Administrative Aide I', NULL, 'KP-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(356, 'KPFH-C167', 'Chavez', 'Allan', 'R.', 'Administrative Aide I', NULL, 'GEAMH-Dialysis Extension Clinic', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(357, 'KPFH-C168', 'Gabas', 'Narciso', 'D.', 'Administrative Aide I', NULL, 'KP-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(358, 'KPFH-C169', 'Jacob', 'Joseph', 'P.', 'Administrative Aide I', NULL, 'GEAMH-Laboratory', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(359, 'KPFH-C170', 'Llamado', 'Gerry', 'V.', 'Administrative Aide I', NULL, 'KP-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(360, 'KPFH-C171', 'Maligmat', 'Jonald', 'Q.', 'Administrative Aide I', NULL, 'GEAMH-Maintenance', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(361, 'KPFH-C172', 'Retutar', 'Jemeniano', 'C.', 'Administrative Aide I', NULL, 'KP-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(362, 'KPFH-C173', 'Romero', 'Radie', 'M.', 'Administrative Aide I', NULL, 'GEAMH-Medical Arts Building', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(363, 'KPFH-C174', 'Romilla', 'Richard', 'A.', 'Administrative Aide I', NULL, 'KP-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(364, 'KPFH-C175', 'Tubid', 'Alexander', 'L.', 'Administrative Aide I', NULL, 'GEAMH-Nursing', 'Casual', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-04-24 03:45:20', '2026-05-22 02:49:59'),
(366, 'GEAMH-666', 'Sismaet', 'Angeline', 'Dondoyano', 'Nurse IV', '', 'GEAMH-Nursing', '', '2026-02-25', '2004-10-06', 0, '', 'Married', 'Ormoc City', '09909090900', 'angel@geamh.gov.ph', '0.00', '0', '', '', '', '', 1, '2026-05-09 05:50:37', '2026-05-22 03:07:28'),
(370, '1010', 'DIEZ', 'JOHN BENNETH', 'NAAGAS', 'Security Guard I', '', 'GEAMH-Maintenance', 'Casual', '1995-03-16', '2004-05-28', 0, '', 'Widowed', 'TIMALAN NAIC CAVITE', '09121212121', 'johnbenneth12@gmail.com', '200000.00', '0', '', '', '', '', 1, '2026-05-16 02:29:45', '2026-05-22 03:07:28'),
(371, 'GEAMH-111', 'Consunji', 'Shawn Mico', '', '', '', '', 'Permanent', NULL, '1999-05-31', 0, '', 'Separated', 'De Ocampo, TMC', '09090909090', 'shawn@geamh.gov.ph', '0.00', '0', '', '', '', '', 1, '2026-05-18 06:07:33', '2026-05-18 06:08:25'),
(373, 'EMR-001', 'LUGAY', 'HERBERT C.', '', 'Administrative Assistant VI', NULL, 'Electronic Medical Records (EMR)', 'Permanent', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-05-27 16:46:01', '2026-05-27 16:46:01'),
(374, 'EMR-002', 'BATES', 'JULY A.', '', 'Records Officer I', NULL, 'Electronic Medical Records (EMR)', 'Permanent', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-05-27 16:46:01', '2026-05-27 16:46:01'),
(375, 'EMR-003', 'AGRIMANO', 'RHEANBELLE C.', '', 'Computer Operator III', NULL, 'Electronic Medical Records (EMR)', 'Permanent', NULL, NULL, NULL, '', '', NULL, NULL, NULL, '0.00', NULL, NULL, NULL, NULL, NULL, 1, '2026-05-27 16:46:01', '2026-05-27 16:46:01');

-- --------------------------------------------------------

--
-- Table structure for table `leave_records`
--

CREATE TABLE `leave_records` (
  `id` int(10) UNSIGNED NOT NULL,
  `employee_id` int(10) UNSIGNED DEFAULT NULL,
  `employee_no` varchar(20) NOT NULL,
  `employee_name` varchar(150) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `leave_type` enum('Vacation Leave','Sick Leave','Maternity Leave','Paternity Leave','Special Privilege Leave','Special Leave','Forced Leave','Emergency Leave','Study Leave','VAWC Leave','Rehabilitation Leave','Terminal Leave') NOT NULL DEFAULT 'Vacation Leave',
  `date_from` date NOT NULL,
  `date_to` date NOT NULL,
  `days` decimal(5,1) NOT NULL DEFAULT 1.0,
  `reason` text DEFAULT NULL,
  `status` enum('Pending','Approved','Disapproved','Cancelled') NOT NULL DEFAULT 'Pending',
  `approved_by` varchar(100) DEFAULT NULL,
  `date_approved` date DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `leave_records`
--

INSERT INTO `leave_records` (`id`, `employee_id`, `employee_no`, `employee_name`, `department`, `leave_type`, `date_from`, `date_to`, `days`, `reason`, `status`, `approved_by`, `date_approved`, `remarks`, `created_at`, `updated_at`) VALUES
(3, 6, 'GEAMH-C001', 'Agrimano, Rheanbelle C.', 'Information Technology', 'Vacation Leave', '2026-05-30', '2026-05-30', '1.0', '', 'Pending', '', NULL, '', '2026-05-08 07:20:27', '2026-05-08 07:20:27'),
(4, 366, 'GEAMH-666', 'Sismaet, Angeline D.', 'Nursing', 'Forced Leave', '0000-00-00', '0000-00-00', '8.0', '', 'Pending', NULL, NULL, '', '2026-05-09 06:48:55', '2026-05-12 02:33:59');

-- --------------------------------------------------------

--
-- Table structure for table `module_permissions`
--

CREATE TABLE `module_permissions` (
  `id` int(10) UNSIGNED NOT NULL,
  `module` varchar(80) NOT NULL COMMENT 'e.g. Employee Masterlist',
  `role` varchar(40) NOT NULL COMMENT 'DIOS | Super Admin | Admin | Section Admin',
  `action` varchar(30) NOT NULL COMMENT 'View | Add | Edit | Delete | Export | Approve | ...',
  `granted` tinyint(1) NOT NULL DEFAULT 1,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `module_permissions`
--

INSERT INTO `module_permissions` (`id`, `module`, `role`, `action`, `granted`, `updated_by`, `updated_at`) VALUES
(1418, 'Account Management', 'DIOS', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1419, 'Account Management', 'DIOS', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1420, 'Account Management', 'DIOS', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1421, 'Account Management', 'DIOS', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1422, 'Account Management', 'Super Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1423, 'Account Management', 'Super Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1424, 'Account Management', 'Super Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1425, 'Account Management', 'Super Admin', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1426, 'Account Management', 'Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1427, 'Account Management', 'Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1428, 'Account Management', 'Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1429, 'Account Management', 'Admin', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1430, 'Account Management', 'User', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1431, 'Account Management', 'Section Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1432, 'Account Management', 'Section Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1433, 'Account Management', 'Section Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1434, 'Account Management', 'Client', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1435, 'Account Management', 'Client', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1436, 'Account Management', 'Client', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1437, 'Departments', 'DIOS', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1438, 'Departments', 'DIOS', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1439, 'Departments', 'DIOS', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1440, 'Departments', 'DIOS', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1441, 'Departments', 'Super Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1442, 'Departments', 'Super Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1443, 'Departments', 'Super Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1444, 'Departments', 'Super Admin', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1445, 'Departments', 'Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1446, 'Departments', 'Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1447, 'Departments', 'Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1448, 'Departments', 'Admin', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1449, 'Departments', 'User', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1450, 'Departments', 'Section Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1451, 'Departments', 'Section Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1452, 'Departments', 'Section Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1453, 'Departments', 'Client', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1454, 'Departments', 'Client', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1455, 'Departments', 'Client', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1456, 'Employees', 'DIOS', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1457, 'Employees', 'DIOS', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1458, 'Employees', 'DIOS', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1459, 'Employees', 'DIOS', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1460, 'Employees', 'Super Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1461, 'Employees', 'Super Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1462, 'Employees', 'Super Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1463, 'Employees', 'Super Admin', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1464, 'Employees', 'Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1465, 'Employees', 'Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1466, 'Employees', 'Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1467, 'Employees', 'Admin', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1468, 'Employees', 'User', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1469, 'Employees', 'Section Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1470, 'Employees', 'Section Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1471, 'Employees', 'Section Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1472, 'Employees', 'Client', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1473, 'Employees', 'Client', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1474, 'Employees', 'Client', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1475, 'Schedules', 'DIOS', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1476, 'Schedules', 'DIOS', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1477, 'Schedules', 'DIOS', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1478, 'Schedules', 'DIOS', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1479, 'Schedules', 'Super Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1480, 'Schedules', 'Super Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1481, 'Schedules', 'Super Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1482, 'Schedules', 'Super Admin', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1483, 'Schedules', 'Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1484, 'Schedules', 'Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1485, 'Schedules', 'Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1486, 'Schedules', 'Admin', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1487, 'Schedules', 'User', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1488, 'Schedules', 'Section Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1489, 'Schedules', 'Section Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1490, 'Schedules', 'Section Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1491, 'Schedules', 'Client', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1492, 'Schedules', 'Client', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1493, 'Schedules', 'Client', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1494, 'DTR Transmittal', 'DIOS', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1495, 'DTR Transmittal', 'DIOS', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1496, 'DTR Transmittal', 'DIOS', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1497, 'DTR Transmittal', 'DIOS', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1498, 'DTR Transmittal', 'Super Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1499, 'DTR Transmittal', 'Super Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1500, 'DTR Transmittal', 'Super Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1501, 'DTR Transmittal', 'Super Admin', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1502, 'DTR Transmittal', 'Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1503, 'DTR Transmittal', 'Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1504, 'DTR Transmittal', 'Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1505, 'DTR Transmittal', 'Admin', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1506, 'DTR Transmittal', 'User', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1507, 'DTR Transmittal', 'Section Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1508, 'DTR Transmittal', 'Section Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1509, 'DTR Transmittal', 'Section Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1510, 'DTR Transmittal', 'Client', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1511, 'DTR Transmittal', 'Client', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1512, 'DTR Transmittal', 'Client', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1513, 'Leave Management', 'DIOS', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1514, 'Leave Management', 'DIOS', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1515, 'Leave Management', 'DIOS', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1516, 'Leave Management', 'DIOS', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1517, 'Leave Management', 'Super Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1518, 'Leave Management', 'Super Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1519, 'Leave Management', 'Super Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1520, 'Leave Management', 'Super Admin', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1521, 'Leave Management', 'Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1522, 'Leave Management', 'Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1523, 'Leave Management', 'Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1524, 'Leave Management', 'Admin', 'Delete', 1, NULL, '2026-05-28 05:13:47'),
(1525, 'Leave Management', 'User', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1526, 'Leave Management', 'Section Admin', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1527, 'Leave Management', 'Section Admin', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1528, 'Leave Management', 'Section Admin', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1529, 'Leave Management', 'Client', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1530, 'Leave Management', 'Client', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1531, 'Leave Management', 'Client', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1532, 'Travel Orders', 'DIOS', 'View', 1, NULL, '2026-05-28 05:13:47'),
(1533, 'Travel Orders', 'DIOS', 'Add', 1, NULL, '2026-05-28 05:13:47'),
(1534, 'Travel Orders', 'DIOS', 'Edit', 1, NULL, '2026-05-28 05:13:47'),
(1535, 'Travel Orders', 'DIOS', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1536, 'Travel Orders', 'Super Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1537, 'Travel Orders', 'Super Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1538, 'Travel Orders', 'Super Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1539, 'Travel Orders', 'Super Admin', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1540, 'Travel Orders', 'Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1541, 'Travel Orders', 'Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1542, 'Travel Orders', 'Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1543, 'Travel Orders', 'Admin', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1544, 'Travel Orders', 'User', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1545, 'Travel Orders', 'Section Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1546, 'Travel Orders', 'Section Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1547, 'Travel Orders', 'Section Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1548, 'Travel Orders', 'Client', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1549, 'Travel Orders', 'Client', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1550, 'Travel Orders', 'Client', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1551, 'Trainings', 'DIOS', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1552, 'Trainings', 'DIOS', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1553, 'Trainings', 'DIOS', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1554, 'Trainings', 'DIOS', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1555, 'Trainings', 'Super Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1556, 'Trainings', 'Super Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1557, 'Trainings', 'Super Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1558, 'Trainings', 'Super Admin', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1559, 'Trainings', 'Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1560, 'Trainings', 'Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1561, 'Trainings', 'Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1562, 'Trainings', 'Admin', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1563, 'Trainings', 'User', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1564, 'Trainings', 'Section Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1565, 'Trainings', 'Section Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1566, 'Trainings', 'Section Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1567, 'Trainings', 'Client', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1568, 'Trainings', 'Client', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1569, 'Trainings', 'Client', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1570, 'Tracking / Receiving', 'DIOS', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1571, 'Tracking / Receiving', 'DIOS', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1572, 'Tracking / Receiving', 'DIOS', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1573, 'Tracking / Receiving', 'DIOS', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1574, 'Tracking / Receiving', 'Super Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1575, 'Tracking / Receiving', 'Super Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1576, 'Tracking / Receiving', 'Super Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1577, 'Tracking / Receiving', 'Super Admin', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1578, 'Tracking / Receiving', 'Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1579, 'Tracking / Receiving', 'Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1580, 'Tracking / Receiving', 'Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1581, 'Tracking / Receiving', 'Admin', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1582, 'Tracking / Receiving', 'User', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1583, 'Tracking / Receiving', 'Section Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1584, 'Tracking / Receiving', 'Section Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1585, 'Tracking / Receiving', 'Section Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1586, 'Tracking / Receiving', 'Client', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1587, 'Tracking / Receiving', 'Client', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1588, 'Tracking / Receiving', 'Client', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1589, 'Signatories', 'DIOS', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1590, 'Signatories', 'DIOS', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1591, 'Signatories', 'DIOS', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1592, 'Signatories', 'DIOS', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1593, 'Signatories', 'Super Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1594, 'Signatories', 'Super Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1595, 'Signatories', 'Super Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1596, 'Signatories', 'Super Admin', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1597, 'Signatories', 'Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1598, 'Signatories', 'Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1599, 'Signatories', 'Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1600, 'Signatories', 'Admin', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1601, 'Signatories', 'User', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1602, 'Signatories', 'Section Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1603, 'Signatories', 'Section Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1604, 'Signatories', 'Section Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1605, 'Signatories', 'Client', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1606, 'Signatories', 'Client', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1607, 'Signatories', 'Client', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1608, 'Audit Logs', 'DIOS', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1609, 'Audit Logs', 'DIOS', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1610, 'Audit Logs', 'DIOS', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1611, 'Audit Logs', 'DIOS', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1612, 'Audit Logs', 'Super Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1613, 'Audit Logs', 'Super Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1614, 'Audit Logs', 'Super Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1615, 'Audit Logs', 'Super Admin', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1616, 'Audit Logs', 'Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1617, 'Audit Logs', 'Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1618, 'Audit Logs', 'Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1619, 'Audit Logs', 'Admin', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1620, 'Audit Logs', 'User', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1621, 'Audit Logs', 'Section Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1622, 'Audit Logs', 'Section Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1623, 'Audit Logs', 'Section Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1624, 'Audit Logs', 'Client', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1625, 'Audit Logs', 'Client', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1626, 'Audit Logs', 'Client', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1627, 'AI Scanning Tools', 'DIOS', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1628, 'AI Scanning Tools', 'DIOS', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1629, 'AI Scanning Tools', 'DIOS', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1630, 'AI Scanning Tools', 'DIOS', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1631, 'AI Scanning Tools', 'Super Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1632, 'AI Scanning Tools', 'Super Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1633, 'AI Scanning Tools', 'Super Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1634, 'AI Scanning Tools', 'Super Admin', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1635, 'AI Scanning Tools', 'Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1636, 'AI Scanning Tools', 'Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1637, 'AI Scanning Tools', 'Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1638, 'AI Scanning Tools', 'Admin', 'Delete', 1, NULL, '2026-05-28 05:13:48'),
(1639, 'AI Scanning Tools', 'User', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1640, 'AI Scanning Tools', 'Section Admin', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1641, 'AI Scanning Tools', 'Section Admin', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1642, 'AI Scanning Tools', 'Section Admin', 'Edit', 1, NULL, '2026-05-28 05:13:48'),
(1643, 'AI Scanning Tools', 'Client', 'View', 1, NULL, '2026-05-28 05:13:48'),
(1644, 'AI Scanning Tools', 'Client', 'Add', 1, NULL, '2026-05-28 05:13:48'),
(1645, 'AI Scanning Tools', 'Client', 'Edit', 1, NULL, '2026-05-28 05:13:48');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `read_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `type`, `title`, `message`, `reference_id`, `reference_type`, `link`, `is_read`, `created_at`, `read_at`) VALUES
(6, 1, 'employee_updated', 'Employee Updated', 'Rheanbelle  Agrimano\'s information has been updated', 6, 'employee', '/employees', 1, '2026-05-18 06:23:57', '2026-05-18 06:24:22'),
(8, 12, 'employee_updated', 'Employee Updated', 'Rheanbelle  Agrimano\'s information has been updated', 6, 'employee', '/employees', 1, '2026-05-18 06:23:57', '2026-05-18 06:34:59'),
(10, 1, 'employee_updated', 'Employee Updated', 'Rheanbelle  Agrimano\'s information has been updated', 6, 'employee', '/employees', 1, '2026-05-19 06:13:51', '2026-05-19 06:14:22'),
(12, 12, 'employee_updated', 'Employee Updated', 'Rheanbelle  Agrimano\'s information has been updated', 6, 'employee', '/employees', 1, '2026-05-19 06:13:51', '2026-05-25 06:38:55'),
(13, 1, 'employee_updated', 'Employee Updated', 'JOHN BENNETH DIEZ\'s information has been updated', 370, 'employee', '/employees', 1, '2026-05-19 06:35:42', '2026-05-19 06:44:11'),
(15, 12, 'employee_updated', 'Employee Updated', 'JOHN BENNETH DIEZ\'s information has been updated', 370, 'employee', '/employees', 1, '2026-05-19 06:35:42', '2026-05-25 06:38:55'),
(16, 1, 'employee_updated', 'Employee Updated', 'Rheanbelle  Agrimano\'s information has been updated', 6, 'employee', '/employees', 1, '2026-05-19 06:55:10', '2026-05-19 06:55:16'),
(18, 12, 'employee_updated', 'Employee Updated', 'Rheanbelle  Agrimano\'s information has been updated', 6, 'employee', '/employees', 1, '2026-05-19 06:55:10', '2026-05-25 06:38:55'),
(19, 1, 'employee_updated', 'Employee Updated', 'Malaya Abaredes\'s information has been updated', 269, 'employee', '/employees', 1, '2026-05-22 00:40:05', '2026-05-25 06:20:53'),
(21, 12, 'employee_updated', 'Employee Updated', 'Malaya Abaredes\'s information has been updated', 269, 'employee', '/employees', 1, '2026-05-22 00:40:05', '2026-05-25 06:38:55'),
(22, 1, 'employee_updated', 'Employee Updated', 'Rheanbelle  Agrimano\'s information has been updated', 6, 'employee', '/employees', 1, '2026-05-22 00:45:03', '2026-05-25 06:20:56'),
(25, 3, 'password_reset', 'New Password Reset Request', 'Test Personnel User (admin) requested a password reset', 9, 'password_reset_request', '/password-resets', 1, '2026-05-25 06:25:28', '2026-05-25 06:25:35'),
(26, 3, 'password_reset', 'New Password Reset Request', 'Admin (admin1) requested a password reset', 10, 'password_reset_request', '/password-resets', 1, '2026-05-25 06:36:23', '2026-05-25 06:36:32'),
(27, 3, 'password_reset', 'New Password Reset Request', 'Test Admin (test 0) requested a password reset', 11, 'password_reset_request', '/password-resets', 1, '2026-05-28 05:38:32', '2026-05-28 05:38:47'),
(28, 3, 'password_reset', 'New Password Reset Request', 'Test Admin (test 0) requested a password reset', 12, 'password_reset_request', '/password-resets', 1, '2026-05-28 05:41:27', '2026-05-28 05:41:45'),
(29, 3, 'password_reset', 'New Password Reset Request', 'Lugay, Herbert (imis@a) requested a password reset', 13, 'password_reset_request', '/password-resets', 1, '2026-05-28 05:47:09', '2026-05-28 05:47:16'),
(30, 3, 'password_reset', 'New Password Reset Request', 'Lugay, Herbert (imis@a) requested a password reset', 14, 'password_reset_request', '/password-resets', 1, '2026-05-28 05:53:24', '2026-05-28 05:53:34'),
(31, 3, 'password_reset', 'New Password Reset Request', 'Lugay, Herbert (imis@a) requested a password reset', 15, 'password_reset_request', '/password-resets', 1, '2026-05-28 05:55:12', '2026-05-28 06:11:01');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_requests`
--

CREATE TABLE `password_reset_requests` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `user_name` varchar(100) NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `requested_at` datetime DEFAULT current_timestamp(),
  `processed_at` datetime DEFAULT NULL,
  `processed_by` varchar(100) DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `password_reset_requests`
--

INSERT INTO `password_reset_requests` (`id`, `user_id`, `username`, `user_name`, `status`, `requested_at`, `processed_at`, `processed_by`, `notes`) VALUES
(1, 2, 'admin', 'HR Admin', 'approved', '2026-05-16 14:08:59', '2026-05-16 14:14:38', 'DIOS User', NULL),
(2, 4, 'test 0000', 'Test Admin', 'approved', '2026-05-16 14:29:33', '2026-05-16 14:30:27', 'DIOS User', NULL),
(3, 1, 'superadmin', 'Super Admin', 'rejected', '2026-05-16 15:15:27', '2026-05-16 15:15:55', 'DIOS User', NULL),
(4, 1, 'superadmin', 'Super Admin', 'approved', '2026-05-18 09:33:21', '2026-05-18 09:35:14', 'DIOS User', NULL),
(5, 2, 'admin', 'Test Personnel User', 'approved', '2026-05-18 11:43:19', '2026-05-18 11:43:50', 'DIOS User', NULL),
(6, 2, 'admin', 'Test Personnel User', 'approved', '2026-05-18 13:45:00', '2026-05-18 13:45:23', 'DIOS User', NULL),
(7, 12, 'admin1', 'Admin', 'approved', '2026-05-18 13:59:03', '2026-05-18 13:59:39', 'DIOS User', NULL),
(8, 4, 'test 0000', 'Test Admin', 'rejected', '2026-05-19 13:51:37', '2026-05-19 13:52:03', 'DIOS User', NULL),
(9, 2, 'admin', 'Test Personnel User', 'approved', '2026-05-25 14:25:28', '2026-05-25 14:26:53', 'DIOS User', NULL),
(10, 12, 'admin1', 'Admin', 'approved', '2026-05-25 14:36:23', '2026-05-25 14:36:52', 'DIOS User', NULL),
(11, 4, 'test 0', 'Test Admin', 'approved', '2026-05-28 13:38:32', '2026-05-28 13:38:57', 'DIOS User', NULL),
(12, 4, 'test 0', 'Test Admin', 'approved', '2026-05-28 13:41:27', '2026-05-28 13:41:59', 'DIOS User', NULL),
(13, 15, 'imis@a', 'Lugay, Herbert', 'approved', '2026-05-28 13:47:09', '2026-05-28 13:47:23', 'DIOS User', NULL),
(14, 15, 'imis@a', 'Lugay, Herbert', 'approved', '2026-05-28 13:53:24', '2026-05-28 13:54:15', 'DIOS User', NULL),
(15, 15, 'imis@a', 'Lugay, Herbert', 'pending', '2026-05-28 13:55:12', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `payroll_records`
--

CREATE TABLE `payroll_records` (
  `id` int(10) UNSIGNED NOT NULL,
  `employee_id` int(10) UNSIGNED DEFAULT NULL,
  `employee_no` varchar(20) NOT NULL,
  `employee_name` varchar(150) NOT NULL,
  `position` varchar(100) DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `period` varchar(10) NOT NULL COMMENT 'YYYY-MM format',
  `period_label` varchar(50) DEFAULT NULL COMMENT 'e.g. April 2026',
  `basic_salary` decimal(12,2) NOT NULL DEFAULT 0.00,
  `pera` decimal(10,2) NOT NULL DEFAULT 2000.00,
  `rata` decimal(10,2) NOT NULL DEFAULT 0.00,
  `overtime` decimal(10,2) NOT NULL DEFAULT 0.00,
  `night_diff` decimal(10,2) NOT NULL DEFAULT 0.00,
  `gross_pay` decimal(12,2) NOT NULL DEFAULT 0.00,
  `withholding_tax` decimal(10,2) NOT NULL DEFAULT 0.00,
  `gsis` decimal(10,2) NOT NULL DEFAULT 0.00,
  `philhealth` decimal(10,2) NOT NULL DEFAULT 0.00,
  `pagibig` decimal(10,2) NOT NULL DEFAULT 100.00,
  `total_deductions` decimal(12,2) NOT NULL DEFAULT 0.00,
  `net_pay` decimal(12,2) NOT NULL DEFAULT 0.00,
  `status` enum('Pending','Released','On Hold') NOT NULL DEFAULT 'Pending',
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `prc_licenses`
--

CREATE TABLE `prc_licenses` (
  `id` int(11) NOT NULL,
  `employee_id` int(10) UNSIGNED NOT NULL,
  `license_number` varchar(100) NOT NULL,
  `expiry_date` date NOT NULL,
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schedules`
--

CREATE TABLE `schedules` (
  `id` int(10) UNSIGNED NOT NULL,
  `employee_id` int(10) UNSIGNED DEFAULT NULL,
  `employee_no` varchar(20) NOT NULL,
  `employee_name` varchar(150) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `shift` enum('Morning','Afternoon','Night','Split','Flexible') NOT NULL DEFAULT 'Morning',
  `shift_time` varchar(60) DEFAULT NULL COMMENT 'e.g. 07:00 AM - 03:00 PM',
  `days` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Array of day abbreviations e.g. ["Mon","Tue"]' CHECK (json_valid(`days`)),
  `effective_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `rest_day` varchar(60) DEFAULT 'Saturday, Sunday',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `schedule_date` date DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `shift_code` varchar(10) DEFAULT NULL,
  `shift_name` varchar(50) DEFAULT NULL,
  `status` enum('Submitted','Pending','Missing') DEFAULT 'Pending',
  `submitted_date` datetime DEFAULT NULL,
  `last_updated` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `remarks` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `schedules`
--

INSERT INTO `schedules` (`id`, `employee_id`, `employee_no`, `employee_name`, `department`, `shift`, `shift_time`, `days`, `effective_date`, `end_date`, `rest_day`, `created_at`, `updated_at`, `schedule_date`, `start_time`, `end_time`, `shift_code`, `shift_name`, `status`, `submitted_date`, `last_updated`, `created_by`, `remarks`) VALUES
(121, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-01', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(122, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-02', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(123, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-03', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(124, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-04', '08:00:00', '17:00:00', 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(125, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-05', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(126, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-06', '08:00:00', '17:00:00', 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(127, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-07', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(128, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-08', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(129, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-09', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(130, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-10', '08:00:00', '17:00:00', 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(131, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-11', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(132, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-12', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(133, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-13', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(134, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-14', '08:00:00', '17:00:00', 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(135, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-15', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(136, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-16', '08:00:00', '17:00:00', 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(137, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-17', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(138, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-18', '08:00:00', '17:00:00', 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(139, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-19', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(140, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-20', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(141, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-21', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(142, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:02', '2026-05-19 06:59:02', '2026-05-22', '08:00:00', '17:00:00', 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-19 14:59:02', 13, 'test'),
(143, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:03', '2026-05-19 06:59:03', '2026-05-23', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:03', 13, 'test'),
(144, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:03', '2026-05-19 06:59:03', '2026-05-24', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:03', 13, 'test'),
(145, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:03', '2026-05-19 06:59:03', '2026-05-25', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:03', 13, 'test'),
(146, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:03', '2026-05-19 06:59:03', '2026-05-26', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:03', 13, 'test'),
(147, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:03', '2026-05-19 06:59:03', '2026-05-28', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:03', 13, 'test'),
(148, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:03', '2026-05-19 06:59:03', '2026-05-27', '08:00:00', '17:00:00', 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-19 14:59:03', 13, 'test'),
(149, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:03', '2026-05-19 06:59:03', '2026-05-29', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:03', 13, 'test'),
(150, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:03', '2026-05-19 06:59:03', '2026-05-30', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:03', 13, 'test'),
(151, NULL, 'GEAMH-C001', 'Agrimano, Rheanbelle ', 'Information Technology', 'Morning', '', '[]', NULL, NULL, '', '2026-05-19 06:59:03', '2026-05-19 06:59:03', '2026-05-31', '08:00:00', '17:00:00', '85', 'Standard', 'Pending', NULL, '2026-05-19 14:59:03', 13, 'test'),
(152, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"1\":\"H\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-01', NULL, NULL, 'H', 'Holiday', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(153, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"2\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-02', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(154, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"3\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-03', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(155, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"4\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-04', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(156, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"5\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-05', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(157, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"6\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-06', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(158, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"7\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-07', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(159, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"8\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-08', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(160, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"9\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-09', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(161, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"10\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-10', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(162, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"11\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-11', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(163, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"12\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-12', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(164, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"13\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-13', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(165, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"14\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-14', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(166, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"15\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-15', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(167, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"16\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-16', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(168, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"17\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-17', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(169, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"18\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-18', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(170, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"19\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-19', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(171, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"20\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-20', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(172, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"21\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-21', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(173, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"22\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-22', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(174, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"23\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-23', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(175, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"24\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-24', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(176, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"25\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-25', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(177, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"26\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-26', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(178, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"27\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-27', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(179, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"28\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-28', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(180, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"29\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-29', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(181, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"30\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-30', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(182, 373, 'EMR-001', 'HERBERT C. LUGAY', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"31\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-31', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(183, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"1\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-01', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(184, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"2\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-02', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(185, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"3\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-03', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(186, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"4\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-04', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(187, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"5\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-05', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(188, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"6\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-06', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(189, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"7\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-07', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(190, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"8\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-08', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(191, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"9\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-09', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(192, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"10\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-10', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(193, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"11\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-11', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(194, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"12\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-12', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(195, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"13\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-13', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(196, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"14\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-14', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(197, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"15\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-15', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(198, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"16\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-16', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(199, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"17\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-17', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(200, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"18\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-18', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(201, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"19\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-19', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(202, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"20\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-20', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(203, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"21\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-21', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(204, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"22\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-22', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(205, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"23\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-23', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(206, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"24\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-24', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(207, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"25\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-25', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(208, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"26\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-26', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(209, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"27\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-27', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(210, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"28\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-28', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(211, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"29\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-29', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(212, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"30\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-30', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(213, 374, 'EMR-002', 'JULY A. BATES', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"31\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-31', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(214, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"1\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-01', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(215, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"2\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-02', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(216, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"3\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-03', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(217, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"4\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-04', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(218, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"5\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-05', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(219, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"6\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-06', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(220, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"7\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-07', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(221, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"8\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-08', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(222, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"9\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-09', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(223, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"10\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-10', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(224, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"11\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-11', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(225, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"12\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-12', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(226, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"13\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-13', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(227, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"14\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-14', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(228, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"15\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-15', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(229, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"16\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-16', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(230, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"17\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-17', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(231, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"18\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-18', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(232, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"19\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-19', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(233, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"20\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-20', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(234, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"21\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-21', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(235, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"22\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-22', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(236, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"23\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-23', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(237, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"24\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-24', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(238, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"25\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-25', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(239, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"26\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-26', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(240, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"27\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-27', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(241, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"28\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-28', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(242, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"29\":\"85\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-29', '08:00:00', '17:00:00', '85', '8:00am to 5:00pm', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(243, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"30\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-30', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL),
(244, 375, 'EMR-003', 'RHEANBELLE C. AGRIMANO', 'Electronic Medical Records (EMR)', 'Morning', NULL, '{\"31\":\"O\"}', NULL, NULL, 'Saturday, Sunday', '2026-05-27 16:46:50', '2026-05-27 16:46:50', '2026-05-31', NULL, NULL, 'OFF', 'Off Duty', 'Pending', NULL, '2026-05-28 00:46:50', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `schedule_transmittals`
--

CREATE TABLE `schedule_transmittals` (
  `id` int(11) NOT NULL,
  `department` varchar(100) NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `page_number` int(11) DEFAULT 1,
  `staff_count` int(11) DEFAULT 0,
  `submitted_count` int(11) DEFAULT 0,
  `date_submitted` date DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `generated_by` int(11) DEFAULT NULL,
  `generated_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `shift_legends`
--

CREATE TABLE `shift_legends` (
  `id` int(11) NOT NULL,
  `code` varchar(10) NOT NULL,
  `department` varchar(100) DEFAULT NULL COMMENT 'NULL for standard legends',
  `time_range` varchar(50) NOT NULL,
  `color_primary` varchar(7) NOT NULL,
  `color_secondary` varchar(7) DEFAULT NULL,
  `display_order` int(11) DEFAULT 0,
  `active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `shift_legends`
--

INSERT INTO `shift_legends` (`id`, `code`, `department`, `time_range`, `color_primary`, `color_secondary`, `display_order`, `active`, `created_at`, `updated_at`) VALUES
(1, '85', NULL, '8:00 AM - 5:00 PM', '#000000', NULL, 1, 1, '2026-05-18 15:25:35', '2026-05-18 15:25:35'),
(2, 'OFF', NULL, 'Off Duty', '#F44336', NULL, 2, 1, '2026-05-18 15:25:35', '2026-05-18 15:25:35'),
(3, '62', 'Nursing', '6:00 AM - 2:00 PM', '#2196F3', NULL, 1, 1, '2026-05-18 15:25:35', '2026-05-18 15:25:35'),
(4, '210', 'Nursing', '2:00 PM - 10:00 PM', '#4CAF50', NULL, 2, 1, '2026-05-18 15:25:35', '2026-05-18 15:25:35'),
(5, '106', 'Nursing', '10:00 PM - 6:00 AM', '#F44336', NULL, 3, 1, '2026-05-18 15:25:35', '2026-05-18 15:25:35'),
(6, '610', 'Nursing', '6:00 AM - 10:00 PM', '#2196F3', '#4CAF50', 4, 1, '2026-05-18 15:25:35', '2026-05-18 15:25:35'),
(7, '26', 'Nursing', '2:00 PM - 6:00 AM', '#4CAF50', '#F44336', 5, 1, '2026-05-18 15:25:35', '2026-05-18 15:25:35'),
(8, '85', 'Nursing', '8:00 AM - 5:00 PM', '#000000', NULL, 6, 1, '2026-05-18 15:25:35', '2026-05-18 15:25:35'),
(9, 'OFF', 'Nursing', 'Off Duty', '#F44336', NULL, 7, 1, '2026-05-18 15:25:35', '2026-05-18 15:25:35'),
(10, 'H', NULL, 'Holiday', '#F44336', NULL, 3, 1, '2026-05-19 15:32:03', '2026-05-19 15:32:03'),
(11, 'H', NULL, 'Holiday', '#F44336', NULL, 3, 1, '2026-05-20 15:43:14', '2026-05-20 15:43:14'),
(12, '85', NULL, '8:00 AM - 5:00 PM', '#000000', NULL, 1, 1, '2026-05-27 13:17:20', '2026-05-27 13:17:20'),
(13, 'OFF', NULL, 'Off Duty', '#F44336', NULL, 2, 1, '2026-05-27 13:17:20', '2026-05-27 13:17:20'),
(21, '85', NULL, '8:00 AM - 5:00 PM', '#000000', NULL, 1, 1, '2026-05-28 15:00:04', '2026-05-28 15:00:04'),
(22, 'OFF', NULL, 'Off Duty', '#F44336', NULL, 2, 1, '2026-05-28 15:00:04', '2026-05-28 15:00:04');

-- --------------------------------------------------------

--
-- Table structure for table `signatories`
--

CREATE TABLE `signatories` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `position` varchar(100) DEFAULT NULL,
  `role` varchar(100) DEFAULT NULL COMMENT 'e.g. Final Approver, HR Approver',
  `department` varchar(100) DEFAULT NULL,
  `signing_order` tinyint(4) NOT NULL DEFAULT 1,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `signatories`
--

INSERT INTO `signatories` (`id`, `name`, `position`, `role`, `department`, `signing_order`, `active`, `created_at`, `updated_at`) VALUES
(1, 'Dr. Maria Reyes', 'Chief of Hospital', 'Final Approver', 'Office of the Chief', 1, 1, '2026-04-22 08:15:22', '2026-04-22 08:15:22'),
(2, 'Mr. Jose Santos', 'HR Officer IV', 'HR Approver', 'Human Resources', 2, 1, '2026-04-22 08:15:22', '2026-05-11 03:18:51'),
(3, 'Ms. Ana Bautista', 'Administrative Officer V', 'Admin Approver', 'Administrative', 3, 1, '2026-04-22 08:15:22', '2026-04-22 08:15:22'),
(4, 'Mr. Pedro Cruz', 'Accountant III', 'Finance Approver', 'Finance', 4, 1, '2026-04-22 08:15:22', '2026-04-22 08:15:22'),
(5, 'Thea Villanueva', 'HR Clerk II', 'DTR Processor', 'Human Resources', 5, 1, '2026-04-22 08:15:22', '2026-05-15 01:16:16');

-- --------------------------------------------------------

--
-- Table structure for table `trainings`
--

CREATE TABLE `trainings` (
  `id` int(10) UNSIGNED NOT NULL,
  `title` varchar(200) NOT NULL,
  `category` enum('Medical','Nursing','Administrative','Technical','Leadership','Safety','Other') NOT NULL DEFAULT 'Medical',
  `instructor` varchar(150) DEFAULT NULL,
  `venue` varchar(200) DEFAULT NULL,
  `date_from` date NOT NULL,
  `date_to` date DEFAULT NULL,
  `duration` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'Number of days',
  `max_participants` smallint(6) NOT NULL DEFAULT 30,
  `enrolled` smallint(6) NOT NULL DEFAULT 0,
  `status` enum('Upcoming','Ongoing','Completed','Cancelled') NOT NULL DEFAULT 'Upcoming',
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trainings`
--

INSERT INTO `trainings` (`id`, `title`, `category`, `instructor`, `venue`, `date_from`, `date_to`, `duration`, `max_participants`, `enrolled`, `status`, `description`, `created_at`, `updated_at`) VALUES
(1, 'IT Training', 'Technical', 'Mr. Herbert Lugay', 'OPHO', '2026-04-30', '2026-04-30', 1, 30, 1, 'Upcoming', 'test', '2026-04-24 07:46:01', '2026-04-24 07:54:52'),
(2, 'HR Training', 'Administrative', '', 'OPHO', '2026-05-02', '2026-05-03', 2, 30, 0, 'Upcoming', 'TEST', '2026-04-24 07:49:25', '2026-05-15 01:34:29'),
(4, 'Basic Communication', 'Leadership', 'Diez', 'Mall of asia', '2026-06-16', '2026-02-11', 1, 30, 1, 'Upcoming', 'Communication on how to handle stress and patient.', '2026-05-16 02:41:04', '2026-05-16 02:44:06'),
(5, 'Anti-selos Training Seminar', 'Safety', 'Jak Roberto', 'geamh', '2026-05-30', '2026-05-30', 1, 30, 2, 'Upcoming', 'huhuhuhuhu', '2026-05-16 06:41:33', '2026-05-19 02:11:06');

-- --------------------------------------------------------

--
-- Table structure for table `training_participants`
--

CREATE TABLE `training_participants` (
  `id` int(10) UNSIGNED NOT NULL,
  `training_id` int(10) UNSIGNED NOT NULL,
  `employee_id` int(10) UNSIGNED NOT NULL,
  `attended` tinyint(1) NOT NULL DEFAULT 0,
  `remarks` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `training_participants`
--

INSERT INTO `training_participants` (`id`, `training_id`, `employee_id`, `attended`, `remarks`) VALUES
(1, 1, 6, 1, ''),
(3, 4, 370, 0, NULL),
(4, 5, 366, 0, NULL),
(5, 5, 370, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `travel_orders`
--

CREATE TABLE `travel_orders` (
  `id` int(10) UNSIGNED NOT NULL,
  `employee_id` int(10) UNSIGNED DEFAULT NULL,
  `employee_no` varchar(20) NOT NULL,
  `employee_name` varchar(150) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `destination` varchar(255) NOT NULL,
  `purpose` text DEFAULT NULL,
  `date_from` date NOT NULL,
  `date_to` date NOT NULL,
  `days` tinyint(4) NOT NULL DEFAULT 1,
  `transport` enum('Public Transport','Government Vehicle','Private Vehicle') NOT NULL DEFAULT 'Public Transport',
  `approved_by` varchar(100) DEFAULT NULL,
  `status` enum('Pending','Approved','Disapproved') NOT NULL DEFAULT 'Pending',
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `travel_orders`
--

INSERT INTO `travel_orders` (`id`, `employee_id`, `employee_no`, `employee_name`, `department`, `destination`, `purpose`, `date_from`, `date_to`, `days`, `transport`, `approved_by`, `status`, `remarks`, `created_at`, `updated_at`) VALUES
(1, 366, 'GEAMH-666', 'Sismaet, Angeline D.', 'Nursing', 'Ecert', 'secret', '0000-00-00', '0000-00-00', 1, 'Public Transport', NULL, 'Pending', '', '2026-05-09 08:14:48', '2026-05-12 02:30:17');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` varchar(50) NOT NULL,
  `biometrics_number` varchar(20) DEFAULT NULL COMMENT 'Biometrics number for login (alternative to username)',
  `password` varchar(64) NOT NULL COMMENT 'SHA-256 hash',
  `name` varchar(100) NOT NULL,
  `role` enum('DIOS','Super Admin','Admin','User','Section Admin','Client') NOT NULL DEFAULT 'Admin',
  `department` varchar(100) NOT NULL DEFAULT 'Human Resources',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `position` varchar(150) DEFAULT NULL COMMENT 'User position/title for signatories'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `biometrics_number`, `password`, `name`, `role`, `department`, `active`, `created_at`, `updated_at`, `position`) VALUES
(1, 'supera', NULL, '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Super Admin', 'Super Admin', 'Human Resources', 1, '2026-04-22 08:15:22', '2026-05-28 06:01:30', 'System Administrator'),
(2, 'admin', NULL, '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Test Personnel User', '', '', 1, '2026-04-22 08:15:22', '2026-05-28 06:01:30', NULL),
(3, 'dios12', NULL, '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'DIOS User', 'DIOS', '', 1, '2026-05-13 06:47:09', '2026-05-28 06:01:30', ''),
(4, 'test 0', NULL, '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Test Admin', 'Section Admin', 'Nursing', 1, '2026-05-13 07:11:02', '2026-05-28 06:01:30', 'Nurse II'),
(12, 'admin1', NULL, '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Admin', 'Admin', 'Human Resources', 1, '2026-05-16 05:56:15', '2026-05-25 06:36:52', 'Administrative Aide III'),
(15, 'imis@a', NULL, '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Lugay, Herbert', 'Section Admin', 'Information Technology', 1, '2026-05-19 07:23:24', '2026-05-28 06:01:30', 'Computer Operator II');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ai_scanned_docs`
--
ALTER TABLE `ai_scanned_docs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_ai_user` (`uploaded_by`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_log_module` (`module`),
  ADD KEY `idx_log_user` (`user_id`),
  ADD KEY `idx_log_created` (`created_at`),
  ADD KEY `idx_log_action_type` (`action_type`),
  ADD KEY `idx_log_affected_table` (`affected_table`),
  ADD KEY `idx_log_record_id` (`record_id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `idx_dept_name` (`name`),
  ADD KEY `idx_dept_active` (`active`);

--
-- Indexes for table `document_tracking`
--
ALTER TABLE `document_tracking`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_track_docno` (`doc_no`),
  ADD KEY `idx_track_status` (`status`);

--
-- Indexes for table `dtr_history`
--
ALTER TABLE `dtr_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_dtrh_emp` (`employee_no`),
  ADD KEY `idx_dtrh_action` (`action`),
  ADD KEY `idx_dtrh_date` (`created_at`);

--
-- Indexes for table `dtr_records`
--
ALTER TABLE `dtr_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_dtr_emp` (`employee_no`),
  ADD KEY `idx_dtr_status` (`status`),
  ADD KEY `idx_dtr_period` (`period`),
  ADD KEY `fk_dtr_emp` (`employee_id`);

--
-- Indexes for table `dtr_signatories`
--
ALTER TABLE `dtr_signatories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_dtr_sig` (`dtr_id`,`signatory_id`),
  ADD KEY `fk_dtrsig_sig` (`signatory_id`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `employee_no` (`employee_no`),
  ADD KEY `idx_emp_no` (`employee_no`),
  ADD KEY `idx_dept` (`department`),
  ADD KEY `idx_status` (`employment_status`),
  ADD KEY `idx_bdate` (`birth_date`);

--
-- Indexes for table `leave_records`
--
ALTER TABLE `leave_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_leave_emp` (`employee_no`),
  ADD KEY `idx_leave_status` (`status`),
  ADD KEY `idx_leave_dates` (`date_from`,`date_to`),
  ADD KEY `fk_leave_emp` (`employee_id`);

--
-- Indexes for table `module_permissions`
--
ALTER TABLE `module_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_module_role_action` (`module`,`role`,`action`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_is_read` (`is_read`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_user_read` (`user_id`,`is_read`);

--
-- Indexes for table `password_reset_requests`
--
ALTER TABLE `password_reset_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_requested_at` (`requested_at`);

--
-- Indexes for table `payroll_records`
--
ALTER TABLE `payroll_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pay_emp` (`employee_no`),
  ADD KEY `idx_pay_period` (`period`),
  ADD KEY `idx_pay_status` (`status`),
  ADD KEY `fk_pay_emp` (`employee_id`);

--
-- Indexes for table `prc_licenses`
--
ALTER TABLE `prc_licenses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `employee_id` (`employee_id`,`license_number`),
  ADD KEY `idx_prc_employee_id` (`employee_id`),
  ADD KEY `idx_prc_expiry_date` (`expiry_date`);

--
-- Indexes for table `schedules`
--
ALTER TABLE `schedules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_employee_date` (`employee_no`,`schedule_date`),
  ADD KEY `idx_sched_emp` (`employee_no`),
  ADD KEY `idx_sched_dept` (`department`),
  ADD KEY `fk_sched_emp` (`employee_id`),
  ADD KEY `idx_schedule_date` (`schedule_date`),
  ADD KEY `idx_shift_code` (`shift_code`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `schedule_transmittals`
--
ALTER TABLE `schedule_transmittals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_department` (`department`),
  ADD KEY `idx_period` (`period_start`,`period_end`);

--
-- Indexes for table `shift_legends`
--
ALTER TABLE `shift_legends`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_code_dept` (`code`,`department`),
  ADD KEY `idx_department` (`department`),
  ADD KEY `idx_active` (`active`);

--
-- Indexes for table `signatories`
--
ALTER TABLE `signatories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sig_order` (`signing_order`);

--
-- Indexes for table `trainings`
--
ALTER TABLE `trainings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_train_status` (`status`),
  ADD KEY `idx_train_category` (`category`),
  ADD KEY `idx_train_date` (`date_from`);

--
-- Indexes for table `training_participants`
--
ALTER TABLE `training_participants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_train_emp` (`training_id`,`employee_id`),
  ADD KEY `fk_tp_emp` (`employee_id`);

--
-- Indexes for table `travel_orders`
--
ALTER TABLE `travel_orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_to_emp` (`employee_no`),
  ADD KEY `idx_to_status` (`status`),
  ADD KEY `fk_to_emp` (`employee_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `idx_biometrics_number` (`biometrics_number`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `ai_scanned_docs`
--
ALTER TABLE `ai_scanned_docs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=609;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT for table `document_tracking`
--
ALTER TABLE `document_tracking`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `dtr_history`
--
ALTER TABLE `dtr_history`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `dtr_records`
--
ALTER TABLE `dtr_records`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `dtr_signatories`
--
ALTER TABLE `dtr_signatories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employees`
--
ALTER TABLE `employees`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=376;

--
-- AUTO_INCREMENT for table `leave_records`
--
ALTER TABLE `leave_records`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `module_permissions`
--
ALTER TABLE `module_permissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1646;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `password_reset_requests`
--
ALTER TABLE `password_reset_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `payroll_records`
--
ALTER TABLE `payroll_records`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `prc_licenses`
--
ALTER TABLE `prc_licenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `schedules`
--
ALTER TABLE `schedules`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=245;

--
-- AUTO_INCREMENT for table `schedule_transmittals`
--
ALTER TABLE `schedule_transmittals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `shift_legends`
--
ALTER TABLE `shift_legends`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `signatories`
--
ALTER TABLE `signatories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `trainings`
--
ALTER TABLE `trainings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `training_participants`
--
ALTER TABLE `training_participants`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `travel_orders`
--
ALTER TABLE `travel_orders`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `ai_scanned_docs`
--
ALTER TABLE `ai_scanned_docs`
  ADD CONSTRAINT `fk_ai_user` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `dtr_records`
--
ALTER TABLE `dtr_records`
  ADD CONSTRAINT `fk_dtr_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `dtr_signatories`
--
ALTER TABLE `dtr_signatories`
  ADD CONSTRAINT `fk_dtrsig_dtr` FOREIGN KEY (`dtr_id`) REFERENCES `dtr_records` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dtrsig_sig` FOREIGN KEY (`signatory_id`) REFERENCES `signatories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `leave_records`
--
ALTER TABLE `leave_records`
  ADD CONSTRAINT `fk_leave_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `payroll_records`
--
ALTER TABLE `payroll_records`
  ADD CONSTRAINT `fk_pay_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `prc_licenses`
--
ALTER TABLE `prc_licenses`
  ADD CONSTRAINT `prc_licenses_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `schedules`
--
ALTER TABLE `schedules`
  ADD CONSTRAINT `fk_sched_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `training_participants`
--
ALTER TABLE `training_participants`
  ADD CONSTRAINT `fk_tp_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tp_training` FOREIGN KEY (`training_id`) REFERENCES `trainings` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `travel_orders`
--
ALTER TABLE `travel_orders`
  ADD CONSTRAINT `fk_to_emp` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
