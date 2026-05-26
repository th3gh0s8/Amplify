<?php
/**
 * Helper to send FCM notifications via Google FCM V1 API
 * Requires: Service Account JSON file (download from Firebase Console -> Project Settings -> Service Accounts)
 */

function sendFCM($target_token, $title, $message) {
    // 1. You must place your service account JSON file here
    $service_account_file = 'firebase_credentials.json'; 
    
    if (!file_exists($service_account_file)) {
        error_log("FCM Error: Credentials file missing.");
        return false;
    }

    // Since we can't easily do OAuth2 without library, here is the CURL approach 
    // for LEGACY API (simpler for basic PHP setups). 
    // IF YOU WANT V1, YOU NEED COMPOSER + GOOGLE AUTH LIBRARY.
    
    // Fallback to Legacy Server Key (get from Cloud Messaging tab in Firebase Console)
    $server_key = 'YOUR_LEGACY_SERVER_KEY_HERE'; 

    $url = 'https://fcm.googleapis.com/fcm/send';

    $fields = [
        'to' => $target_token,
        'notification' => [
            'title' => $title,
            'body' => $message,
            'sound' => 'default',
            'badge' => '1'
        ],
        'priority' => 'high'
    ];

    $headers = [
        'Authorization: key=' . $server_key,
        'Content-Type: application/json'
    ];

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
    
    $result = curl_exec($ch);
    curl_close($ch);

    return $result;
}

/**
 * Send to all tokens for a specific partner or all partners
 */
function pushToPartner($conn, $partner_id, $title, $message) {
    $sql = "SELECT fcm_token FROM partners WHERE fcm_token IS NOT NULL AND fcm_token != ''";
    if ($partner_id > 0) {
        $sql .= " AND ID = " . (int)$partner_id;
    }
    
    $res = $conn->query($sql);
    while ($row = $res->fetch_assoc()) {
        sendFCM($row['fcm_token'], $title, $message);
    }
}
?>
