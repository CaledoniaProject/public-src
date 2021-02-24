# LWP 忽略 SSL 错误

my $ua = LWP::UserAgent->new (
   ssl_opts => { verify_hostname => 0 }
);