<?php
$url = 'https://www.bing.com';
$options = array(
    'http' => array(
        'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
        'method'  => 'POST',
        'content' => http_build_query(array ('name' => 'test')),
    ),
);
$context  = stream_context_create($options);
echo file_get_contents($url, false, $context);
?>
