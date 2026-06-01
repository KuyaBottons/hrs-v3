<?php
require_once 'db.php';
require_once 'cors.php';

$method = $_SERVER['REQUEST_METHOD'];
$conn   = getConnection();
$userId = (int)($_SERVER['HTTP_X_USER_ID'] ?? 0);

// Check permission before processing request (Birthday Celebrants is View-only)
if (!checkPermission($conn, $userId, 'Birthday Celebrants', 'View')) {
    denyAccess('Birthday Celebrants', 'View');
}

if ($method !== 'GET') {
    sendError('Method not allowed', 405);
}

// ── Query params ─────────────────────────────────────────────────────────────
// ?month=4          → celebrants for a specific month (1-12), defaults to current month
// ?view=month       → full month view (default)
// ?view=7days       → next 7 days
// ?view=14days      → next 14 days
// ?view=30days      → next 30 days
// ?view=60days      → next 60 days
// ?turning65=1      → employees turning 65 this calendar year
// ?search=name      → filter by name (optional, combined with month)
// ─────────────────────────────────────────────────────────────────────────────

$year  = (int) date('Y');
$month = isset($_GET['month']) ? (int) $_GET['month'] : (int) date('n');
$month = max(1, min(12, $month)); // clamp 1-12

$search     = trim($_GET['search'] ?? '');
$turning65  = isset($_GET['turning65']) && $_GET['turning65'] == '1';
$view       = $_GET['view'] ?? 'month';
$department = trim($_GET['department'] ?? '');

// Base columns we always return
$select = "
    id,
    employee_no,
    last_name,
    first_name,
    middle_name,
    position,
    department,
    employment_status,
    birth_date,
    gender,
    email,
    active,
    TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS current_age,
    YEAR(CURDATE()) - YEAR(birth_date)         AS age_this_year,
    DATE_FORMAT(birth_date, '%m-%d')           AS birth_mmdd,
    DAYOFMONTH(birth_date)                     AS birth_day
";

if ($turning65) {
    // ── Employees turning 65 this calendar year ───────────────────────────
    $sql = "
        SELECT $select
        FROM employees
        WHERE active = 1
          AND birth_date IS NOT NULL
          AND YEAR(CURDATE()) - YEAR(birth_date) = 65
        ORDER BY birth_date ASC
    ";
    $stmt = $conn->prepare($sql);
    $stmt->execute();

} else {
    // ── Celebrants for the requested month or date range ─────────────────
    $viewDays = 0;
    if ($view === '7days') $viewDays = 7;
    elseif ($view === '14days') $viewDays = 14;
    elseif ($view === '30days') $viewDays = 30;
    elseif ($view === '60days') $viewDays = 60;

    if ($viewDays > 0) {
        // Date range view (next X days)
        $startDate = date('Y-m-d');
        $endDate = date('Y-m-d', strtotime("+$viewDays days"));

        if ($search !== '' && $department !== '') {
            $like = '%' . $search . '%';
            $sql = "
                SELECT $select
                FROM employees
                WHERE active = 1
                  AND birth_date IS NOT NULL
                  AND department = ?
                  AND DATE(CONCAT(YEAR(CURDATE()), '-', DATE_FORMAT(birth_date, '%m-%d'))) BETWEEN ? AND ?
                  AND (last_name LIKE ? OR first_name LIKE ?)
                ORDER BY DAYOFMONTH(birth_date) ASC
            ";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('sssss', $department, $startDate, $endDate, $like, $like);
        } elseif ($department !== '') {
            $sql = "
                SELECT $select
                FROM employees
                WHERE active = 1
                  AND birth_date IS NOT NULL
                  AND department = ?
                  AND DATE(CONCAT(YEAR(CURDATE()), '-', DATE_FORMAT(birth_date, '%m-%d'))) BETWEEN ? AND ?
                ORDER BY DAYOFMONTH(birth_date) ASC
            ";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('sss', $department, $startDate, $endDate);
        } elseif ($search !== '') {
            $like = '%' . $search . '%';
            $sql = "
                SELECT $select
                FROM employees
                WHERE active = 1
                  AND birth_date IS NOT NULL
                  AND DATE(CONCAT(YEAR(CURDATE()), '-', DATE_FORMAT(birth_date, '%m-%d'))) BETWEEN ? AND ?
                  AND (last_name LIKE ? OR first_name LIKE ?)
                ORDER BY DAYOFMONTH(birth_date) ASC
            ";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('ssss', $startDate, $endDate, $like, $like);
        } else {
            $sql = "
                SELECT $select
                FROM employees
                WHERE active = 1
                  AND birth_date IS NOT NULL
                  AND DATE(CONCAT(YEAR(CURDATE()), '-', DATE_FORMAT(birth_date, '%m-%d'))) BETWEEN ? AND ?
                ORDER BY DAYOFMONTH(birth_date) ASC
            ";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('ss', $startDate, $endDate);
        }
    } else {
        // Full month view (default)
        if ($search !== '' && $department !== '') {
            $like = '%' . $search . '%';
            $sql = "
                SELECT $select
                FROM employees
                WHERE active = 1
                  AND birth_date IS NOT NULL
                  AND MONTH(birth_date) = ?
                  AND department = ?
                  AND (last_name LIKE ? OR first_name LIKE ?)
                ORDER BY DAYOFMONTH(birth_date) ASC
            ";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('isss', $month, $department, $like, $like);
        } elseif ($department !== '') {
            $sql = "
                SELECT $select
                FROM employees
                WHERE active = 1
                  AND birth_date IS NOT NULL
                  AND MONTH(birth_date) = ?
                  AND department = ?
                ORDER BY DAYOFMONTH(birth_date) ASC
            ";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('is', $month, $department);
        } elseif ($search !== '') {
            $like = '%' . $search . '%';
            $sql = "
                SELECT $select
                FROM employees
                WHERE active = 1
                  AND birth_date IS NOT NULL
                  AND MONTH(birth_date) = ?
                  AND (last_name LIKE ? OR first_name LIKE ?)
                ORDER BY DAYOFMONTH(birth_date) ASC
            ";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('iss', $month, $like, $like);
        } else {
            $sql = "
                SELECT $select
                FROM employees
                WHERE active = 1
                  AND birth_date IS NOT NULL
                  AND MONTH(birth_date) = ?
                ORDER BY DAYOFMONTH(birth_date) ASC
            ";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('i', $month);
        }
    }
    $stmt->execute();
}

$rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

// ── Enrich each row ──────────────────────────────────────────────────────────
$today     = new DateTime();
$thisYear  = (int) $today->format('Y');

foreach ($rows as &$r) {
    // Days until next birthday
    $bd   = new DateTime($r['birth_date']);
    $next = new DateTime($thisYear . '-' . $bd->format('m-d'));
    if ($next < $today) {
        $next->modify('+1 year');
    }
    $diff = (int) $today->diff($next)->days;
    $r['days_until_birthday'] = $diff;
    $r['is_today']            = $diff === 0;

    // Formatted birthday label  e.g. "April 16"
    $r['birthday_label'] = $bd->format('F j');

    // Retirement flag
    $r['is_retirement_age'] = (int)$r['age_this_year'] >= 65;
}
unset($r);

// ── Summary meta ────────────────────────────────────────────────────────────
$monthNames = [
    1=>'January',2=>'February',3=>'March',4=>'April',
    5=>'May',6=>'June',7=>'July',8=>'August',
    9=>'September',10=>'October',11=>'November',12=>'December',
];

sendJson([
    'month'              => $month,
    'month_name'         => $monthNames[$month] ?? '',
    'year'               => $thisYear,
    'total'              => count($rows),
    'celebrants'         => $rows,
    'missing_birth_date' => (int) $conn->query(
        'SELECT COUNT(*) FROM employees WHERE active = 1 AND (birth_date IS NULL OR birth_date = "")'
    )->fetch_row()[0],
]);

$conn->close();
