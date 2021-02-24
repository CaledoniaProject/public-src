# 类似 File::Slurp

# 可选，设置最多一次读取 32768 行
# local $/ = \32768;

my $file = do { open my $fh, '/etc/passwd'; local $/ = <$fh>; };
print $file;

