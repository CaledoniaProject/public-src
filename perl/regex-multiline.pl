# 默认匹配不会跨行，加上 s 标记之后可以跨行

my $multi_line = "123\n456";

if ($multi_line =~ /123.*456/s)
{
    print "Matched\n";
}
