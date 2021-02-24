<?php
   $tokens = token_get_all(file_get_contents ('a.php'));

   foreach ($tokens as $token) {
      if (is_array($token)) {
         if (in_array ($token[0], array (T_WHITESPACE, T_ENCAPSED_AND_WHITESPACE, T_CONSTANT_ENCAPSED_STRING, T_DOC_COMMENT)))
         {
            $token[1] = "X";
         }
         echo $token[1], "\n";
         echo "Line {$token[2]}: ", token_name($token[0]), " ('{$token[1]}')", PHP_EOL;
      }
   }

?>

