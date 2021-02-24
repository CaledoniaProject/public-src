# 检查正则是否正确

my $regex = "[";

eval {
  qr /$regex/;
};
if ($@) {
  print "Regex is invalid, $@";
}