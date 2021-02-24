<?php

$time = @strtotime("2011-01-01 10:10:10");
@touch('/tmp/test.txt', $time, $time);

?>
