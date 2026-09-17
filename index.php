<?php
/**
 * QR Attendance System Using MS SQL and Apache
 * Root Route Gateway & Redirector
 */

require_once __DIR__ . '/config/config.php';

if (empty($_SESSION['user_id']) || empty($_SESSION['user_role'])) {
    header('Location: ' . BASE_URL . '/auth/login.php');
    exit;
}

// Redirect authenticated users to their corresponding dashboard
switch ($_SESSION['user_role']) {
    case 'Admin':
        header('Location: ' . BASE_URL . '/admin/index.php');
        break;
    case 'Lecturer':
        header('Location: ' . BASE_URL . '/lecturer/index.php');
        break;
    case 'Student':
        header('Location: ' . BASE_URL . '/student/index.php');
        break;
    default:
        header('Location: ' . BASE_URL . '/auth/login.php');
        break;
}
exit;
