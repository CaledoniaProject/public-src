# 出错自动退出

use autodie qw(open :socket); 
open my $fh, '/i/dont/exist';
