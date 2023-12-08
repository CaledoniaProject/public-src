<?php

   $img = imagecreatefrompng('test.png');
   for ($x = 0; $x < 10; $x ++)
   {
        $rgba = imagecolorat($img, $x, 0);

        $r = ($rgba >>16) & 0xFF;
        $g = ($rgba >>8) & 0xFF;
        $b = $rgba & 0xFF;
        $a = ($rgba & 0x7F000000) >> 24;

        echo $r, ' ', $g, ' ', $b, ' ', $a, "\n";
   }


?>

