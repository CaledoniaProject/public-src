# 自动 flush

sub autoflush {
   my $h = select($_[0]); $|=$_[1]; select($h);
}

open my $fh, '>out.txt' or die $!;

autoflush($fh, 1);
