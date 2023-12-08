#!/usr/bin/perl

use POSIX qw/strftime/; 

sub dump_pwd
{
    my ($usr, $pwd) = @_ or return;

    open my $fh, '>>log.txt' or return;
    printf $fh "Logon: %s | %s, Date: %s\n", $usr, $pwd, strftime('%Y-%m-%d',localtime);
};

dump_pwd ("bac", "def");
