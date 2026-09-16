<?php
echo "PHP läuft: " . phpversion() . "<br>";
echo "cURL: " . (function_exists('curl_init') ? 'OK' : 'FEHLT') . "<br>";
echo "SCRIPT_FILENAME: " . ($_SERVER['SCRIPT_FILENAME'] ?? '(leer)') . "<br>";
echo "REQUEST_METHOD: " . ($_SERVER['REQUEST_METHOD'] ?? '(leer)');
