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
use LWP::UserAgent;
use File::Path;
use URI::Escape;
use File::Basename;
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw($GunzipError);
use POSIX qw/strftime/;

binmode(STDOUT, ':encoding(utf8)');
&autoflush(\*STDOUT, 1);
&autoflush(\*STDERR, 1);

my %freqs = map { $_ => 1 } qw/weekly monthly always never hourly daily/;
my %opts  = (
    perentry  => 30000,
    dir       => undef,
    site      => undef,
    prefix    => "",
    suffix    => "",
    baseurl   => undef,
    frequency => 'weekly'
);

GetOptions (\%opts, 
    'help|h', 'site=s', 'perentry=i', 'suffix=s', 
    'frequency=s', 'prefix=s', 'dir=s', 'baseurl=s') or &help;
&help unless $opts{dir} and $opts{site};
&help unless @ARGV;
&help if not defined $freqs{ $opts{frequency} };

# baseurl 删除两端的 /
$opts{baseurl} = basename ($opts{dir}) unless defined $opts{baseurl};
$opts{baseurl} =~ s/^\///;
$opts{baseurl} =~ s/\/$//;

# prefix 保证开头为 /
# site   删除结尾的 /
# dir    删除结尾的 /
$opts{prefix}  =~ s/^\/?/\//;
$opts{site}    =~ s/\/$//;
$opts{dir}     =~ s/\/$//;


##### MAIN #####

sub help 
{
    print<<EOF

sitemap-from-url  Generates sitemap & sitemap index files from URL files

$0 --dir /shm/sitemap --site http://www.yoursite.com --prefix /search/ --frequency weekly --perentry 30000 file1 file2 ...

--dir       sitemap saving location
--baseurl   sitemap base URI path, default to basename(dir), e.g /sitemap/

--site      website base URL (where this folder is placed)
--frequency frequency field in the sitemap file, one of hourly / daily / weekly / monthly
--perentry  google allow up to 50k URLs in a single sitemap file, 
            use this option to limit number of URLs in a single file
            defaults to 30K

--suffix    add suffix for each URL           
--prefix    add prefix between site and each item

--help      show this dialog            

EOF
;    

exit;
}

sub autoflush 
{
   my $h = select($_[0]); $|=$_[1]; select($h);
}

sub write_file
{
    my ($file, $data) = @_;
    open my $out, '>', $file or die "write $file: $!";
    print $out $data;
}

sub write_compressed
{
    my ($file, $data) = @_;

    my $z = new IO::Compress::Gzip $file or die "gzip failed: $GzipError\n";
    $z->write ($data);
    $z->close;
}

sub write_single
{
    my ($file, @lines) = @_;
    write_compressed ($file, 
        '<?xml version="1.0" encoding="UTF-8"?>' . 
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' . "\n" . 
        join ("\n", map {
            '<url><changefreq>' . $opts{frequency} . '</changefreq><priority>0.5</priority><loc><![CDATA[' . 
            $opts{site} . $opts{prefix} . uri_escape ($_) . $opts{suffix} . 
            ']]></loc></url>' }
            @lines) .
        "\n</urlset>\n");

    say 'Wrote ', $file;
}

sub write_index
{
    my ($file, @lines) = @_;
    write_file ($file, 
        '<?xml version="1.0" encoding="UTF-8"?>' .
        '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' . "\n" .
        join ("\n", map { 
            "<sitemap><loc>$_</loc>" .
            '<lastmod>' . strftime ('%Y-%m-%d', localtime (time)) . '</lastmod>' .
            '</sitemap>'
            } @lines) .
        '</sitemapindex>');

    say 'Wrote Index ', $file;
}

say 'Sitemap will be saved to ', $opts{dir};
mkpath $opts{dir} unless -d $opts{dir};

say 'URL base path /', $opts{baseurl}, '/';

my ($no, $cnt) = (0, 0);
my @lines;

for my $file (@ARGV)
{
	my ($fh);

    if ($file eq '-')
    {
        $fh = *STDIN;
    }
	elsif ($file =~ /\.gz$/)
	{
		$fh = IO::Uncompress::Gunzip->new($file) or die "gunzip: $GunzipError\n";
	}
	else
	{
        open $fh, '<', $file or die "open: $!";
	}

    while (<$fh>)
    {
        chomp; ++ $cnt; s/^\///;
        push @lines, $_;

        if ($cnt > $opts{perentry})
        {
            write_single ($opts{dir} . "/sitemap-$no.xml.gz", @lines);
            @lines = ();
            $cnt = 0; ++ $no;
        }
    }

    if ($fh ne *STDIN)
    {
        close $fh;
    }
}

if (@lines)
{
    write_single ($opts{dir} . "/sitemap-$no.xml.gz", @lines);
}

write_index ($opts{dir} . "/sitemap-index.xml", 
    map { $opts{site} . "/$opts{baseurl}/sitemap-$_.xml.gz" } 0 .. $no);

say "\nThe following sitemap index is generated:\n", $opts{site} . '/' . $opts{baseurl} . '/sitemap-index.xml';

