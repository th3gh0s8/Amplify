<?php
/**
 * Helper to send FCM notifications via modern Google FCM V1 API
 * Requires: Service Account JSON file saved as 'firebase_credentials.json'
 */

function getGoogleAccessToken() {
    $service_account_file = dirname(__FILE__) . '/firebase_credentials.json';
    
    if (!file_exists($service_account_file)) {
        error_log("FCM V1 Error: Credentials file missing at $service_account_file");
        return null;
    }

    $json = json_decode(file_get_contents($service_account_file), true);
    $private_key = $json['private_key'];
    $client_email = $json['client_email'];

    $header = json_encode(['alg' => 'RS256', 'typ' => 'JWT']);
    $iat = time();
    $exp = $iat + 3600;
    $payload = json_encode([
        'iss' => $client_email,
        'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
        'aud' => 'https://oauth2.googleapis.com/token',
        'exp' => $exp,
        'iat' => $iat
    ]);

    $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
    $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

    $signature = '';
    openssl_sign($base64UrlHeader . "." . $base64UrlPayload, $signature, $private_key, OPENSSL_ALGO_SHA256);
    $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

    $jwt = $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'https://oauth2.googleapis.com/token');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
        'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion' => $jwt
    ]));

    $result = curl_exec($ch);
    curl_close($ch);

    $data = json_decode($result, true);
    return $data['access_token'] ?? null;
}

function sendFCM($target_token, $title, $message) {
    $access_token = getGoogleAccessToken();
    if (!$access_token) return false;

    // Get project_id from credentials
    $json = json_decode(file_get_contents(dirname(__FILE__) . '/firebase_credentials.json'), true);
    $project_id = $json['project_id'];

    $url = "https://fcm.googleapis.com/v1/projects/$project_id/messages:send";

    $fields = [
        'message' => [
            'token' => $target_token,
            'notification' => [
                'title' => $title,
                'body' => $message
            ],
            'android' => [
                'priority' => 'high',
                'notification' => [
                    'sound' => 'default'
                ]
            ]
        ]
    ];

    $headers = [
        'Authorization: Bearer ' . $access_token,
        'Content-Type: application/json'
    ];

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
    
    $result = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($http_code != 200) {
        error_log("FCM V1 Error ($http_code): " . $result);
    }
    
    return $result;
}

function pushToPartner($conn, $partner_id, $title, $message) {
    if ($partner_id > 0) {
        $sql = "SELECT fcm_token FROM partner_devices WHERE partner_id = " . (int)$partner_id;
    } else {
        // Send to ALL devices if partner_id is 0
        $sql = "SELECT fcm_token FROM partner_devices";
    }
    
    $res = $conn->query($sql);
    if ($res) {
        while ($row = $res->fetch_assoc()) {
            sendFCM($row['fcm_token'], $title, $message);
        }
    }
}
?>
