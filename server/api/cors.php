<?php
/**
 * CORS Configuration
 * Handles Cross-Origin Resource Sharing for API requests
 */

// Temporarily disable CORS headers to identify source of duplicate headers
// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
