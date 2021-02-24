#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use lib '/src/cpan';
use Getopt::Long;
use LWP::UserAgent;
use Encode;
use Term::ANSIColor qw/:constants/;
use Term::ANSIColor;
use HTTP::Cookies::Wget;

binmode(STDOUT, ':encoding(utf8)');

my %opts = ('agent' => 'Mozilla/5.0 (iPad; U; CPU OS 3_2_1 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Mobile/7B405');
my $fh = \*STDOUT;
my $ua = LWP::UserAgent->new ( ssl_opts => { verify_hostname => 0 } );

sub usage
{
    print STDERR BOLD WHITE<<EOF

    HTTP Page Scaper, Usage:  

          $0 [options] --regex regex url1 url2 ..

          --regex        specify regular expression
          --split        split string prior to pattern matching
          --cookie       specify mozilla (7 fields) cookie file
          --agent        set user agent
          --output       specify output file (disables color)
          --nocolor      disable colorized output
          --decode       decoded as
          --help         baby you're reading it

EOF
    ;

    exit (1);
}

sub parse_content
{
    my ($content) = @_;
    my $cnt = 0;

    for (split /\n/, $content)
    {
        my $line = $opts{decode} ? decode ($opts{decode}, $_) : $_;
        if ($opts{split})
        {
            for (split /$opts{split}/, $line)
            {
                next if $_ !~ /$opts{regex}/;
                print $&, "\n";

                ++ $cnt;
            }
        }
        else
        {
            print $&, "\n" if /$opts{regex}/;
            ++ $cnt;
        }
    }

    print STDERR BOLD WHITE "[+] Done, ", $cnt, " entries.\n", RESET;

}

GetOptions (\%opts, 'regex|reg|r=s', 'split|s=s', 'help|h', 'decode|d=s',
    'cookie|c=s', 'nocolor|n', 'agent|a=s', 'output|o=s') or usage;

! $opts{regex} && usage;
eval { qr /$opts{regex}/ } or die "Invalid regular expression: $@\n";
$opts{help} && usage;
$ua->agent ($opts{agent});
$ua->cookie_jar (HTTP::Cookies::Wget->new (file => $opts{cookie})) if $opts{cookie};

if ($opts{output})
{
    $opts{nocolor} = 1;
    open $fh, '>', $opts{output} or die $!;
}

for (@ARGV)
{
    $_ = "http://$_" unless $_ =~ /^http/;
    print STDERR BOLD WHITE "[+] Fetching ", GREEN "$_\n", RESET;

    my $r = $ua->get ($_, 'Referer' => $_);

    if ($r->is_success)
    {
        parse_content ($r->decoded_content || $r->content);
        next;
    }

    print STDERR BOLD WHITE "[+] ", RED "Failed: ", $r->status_line, "\n", RESET;
}
