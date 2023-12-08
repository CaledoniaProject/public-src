#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use feature 'say';
use lib '/src/cpan';

use FindBin;
use lib "$FindBin::Bin/lib";
use Getopt::Long;
use Data::Dumper;
use File::Slurp qw/read_file/;
use URI;
use LWP::UserAgent;

binmode(STDOUT, ':encoding(utf8)');

my $ua = LWP::UserAgent->new;
my %opts = (
    'password' => '/tmp/webshell-passwords.txt'
);
GetOptions (\%opts, 'password|p=s', 'debug|d');

my %codes = (
    'php' => {
        'code'   => 'die(md5("greetings"));',
        'expect' => 'f4a04f87cabf65ed55a2db9da2159cd7'
    },
    'phtml' => {
        'code'   => 'die(md5("greetings"));',
        'expect' => 'f4a04f87cabf65ed55a2db9da2159cd7'
    },
    'jsp' => {
        'code'   => 'A',
        'expect' => '->\|.*[\\/].*\|<-',
        'extra'  => {
            'z0' => 'utf8'
        }
    },
    'asp' => {
        'code'   => 'response.write(Hex(1213141125))',
        'expect' => '484F1085'
    },
    'aspx' => {
        'code'   => 'Response.Write(123192038012938-3123123123)',
        'expect' => '123188914889815'
    },
);
my %pass = map { chomp; $_ => 1 } read_file ($opts{password});
$pass{ chr($_) } = 1 for 32 .. 126;

say '[-] Loaded ', scalar keys %pass, ' credentials';
say '[-] Supported extensions: ', join (', ', keys %codes);

for (@ARGV)
{
    $_ = "http://$_" unless $_ =~ /^https?:/;

    my $uri = URI->new ($_);
    (my $ext = $uri->path) =~ s/.*\.//;
    (my $name = $uri->path) =~ s/.*\///; $name =~ s/\..*//;

    my $code = $codes{$ext};
    if (! $code)
    {
        say '[!] Extension ', $ext, ' is not supported';
        next;
    }

    say '[-] Testing ', $uri;
    say '[-] Heuristics suggest ', $name, ' might be a credential as well';
    $pass{$name} = 1;
    
    for my $pass (keys %pass)
    {
        my $resp = $ua->post ($uri, { $pass => $code->{code}, 'z0' => 'utf8' });

        if ($opts{debug})
        {
            say '[!] DEBUG ', $pass;
            say '[!] CODE ', $resp->code;
            say '[!] RESP ', $resp->content;
        }

        if ($resp->content =~ $code->{expect})
        {
            say '[+] Valid credential: ', $pass;
            last;
        }
    }
}

