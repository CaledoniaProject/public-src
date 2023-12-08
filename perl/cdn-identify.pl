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
use Socket;
use Net::IP::Match::Bin;

binmode(STDOUT, ':encoding(utf8)');

my $ranges = {
    '199.27.128.0/21'  => 'cloudflare',
    '173.245.48.0/20'  => 'cloudflare',
    '103.21.244.0/22'  => 'cloudflare',
    '103.22.200.0/22'  => 'cloudflare',
    '103.31.4.0/22'    => 'cloudflare',
    '141.101.64.0/18'  => 'cloudflare',
    '108.162.192.0/18' => 'cloudflare',
    '190.93.240.0/20'  => 'cloudflare',
    '188.114.96.0/20'  => 'cloudflare',
    '197.234.240.0/22' => 'cloudflare',
    '198.41.128.0/17'  => 'cloudflare',
    '162.158.0.0/15'   => 'cloudflare',
    '104.16.0.0/12'    => 'cloudflare',
    '183.136.133.0/24' => '360',
    '220.181.55.0/24'  => '360',
    '101.226.4.0/24'   => '360',
    '180.153.235.0/24' => '360',
    '122.143.15.0/24'  => '360',
    '27.221.20.0/24'   => '360',
    '202.102.85.0/24'  => '360',
    '61.160.224.0/24'  => '360',
    '112.25.60.0/24'   => '360',
    '182.140.227.0/24' => '360',
    '221.204.14.0/24'  => '360',
    '222.73.144.0/24'  => '360',
    '61.240.144.0/24'  => '360',
    '113.17.174.0/24'  => '360',
    '125.88.189.0/24'  => '360',
    '125.88.190.0/24'  => '360',
    '120.52.18.0/24'   => '360',
    '199.83.128.0/21'  => 'incapsula',
    '198.143.32.0/19'  => 'incapsula',
    '149.126.72.0/21'  => 'incapsula',
    '103.28.248.0/22'  => 'incapsula',
    '45.64.64.0/22'    => 'incapsula',
    '185.11.124.0/22'  => 'incapsula',
    '192.230.64.0/18'  => 'incapsula',
    '220.181.135.1/24' => 'anquanbao',
    '115.231.110.1/24' => 'anquanbao',
    '124.202.164.1/24' => 'anquanbao',
    '58.30.212.1/24'   => 'anquanbao',
    '117.25.156.1/24'  => 'anquanbao',
    '36.250.5.1/24'    => 'anquanbao',
    '183.60.136.1/24'  => 'anquanbao',
    '183.61.185.1/24'  => 'anquanbao',
    '14.17.69.1/24'    => 'anquanbao',
    '120.197.85.1/24'  => 'anquanbao',
    '183.232.29.1/24'  => 'anquanbao',
    '61.182.141.1/24'  => 'anquanbao',
    '182.118.12.1/24'  => 'anquanbao',
    '182.118.38.1/24'  => 'anquanbao',
    '61.158.240.1/24'  => 'anquanbao',
    '42.51.25.1/24'    => 'anquanbao',
    '119.97.151.1/24'  => 'anquanbao',
    '58.49.105.1/24'   => 'anquanbao',
    '61.147.92.1/24'   => 'anquanbao',
    '69.28.58.1/24'    => 'anquanbao',
    '176.34.28.1/24'   => 'anquanbao',
    '54.178.75.1/24'   => 'anquanbao',
    '112.253.3.1/24'   => 'anquanbao',
    '119.167.147.1/24' => 'anquanbao',
    '123.129.220.1/24' => 'anquanbao',
    '223.99.255.1/24'  => 'anquanbao',
    '117.34.72.1/24'   => 'anquanbao',
    '117.34.91.1/24'   => 'anquanbao',
    '123.150.187.1/24' => 'anquanbao',
    '221.238.22.1/24'  => 'anquanbao',
    '125.39.32.1/24'   => 'anquanbao',
    '125.39.191.1/24'  => 'anquanbao',
    '125.39.18.1/24'   => 'anquanbao',
    '14.136.130.1/24'  => 'anquanbao',
    '210.209.122.1/24' => 'anquanbao',
    '111.161.66.1/24'  => 'anquanbao',
    '119.188.35.0/24'  => 'jiasule',
    '61.155.222.0/24'  => 'jiasule',
    '218.65.212.0/24'  => 'jiasule',
    '116.211.121.0/24' => 'jiasule',
    '103.15.194.0/24'  => 'jiasule',
    '61.240.149.0/24'  => 'jiasule',
    '222.240.184.0/24' => 'jiasule',
    '112.25.16.0/24'   => 'jiasule',
    '59.52.28.0/24'    => 'jiasule',
    '211.162.64.0/24'  => 'jiasule',
    '180.96.20.0/24'   => 'jiasule',
    '103.1.65.0/24'    => 'jiasule',
    '222.216.190.0/24' => 'yunjiasu',
    '61.155.149.0/24'  => 'yunjiasu',
    '119.188.14.0/24'  => 'yunjiasu',
    '61.182.137.0/24'  => 'yunjiasu',
    '117.34.28.0/24'   => 'yunjiasu',
    '119.188.132.0/24' => 'yunjiasu',
    '42.236.7.0/24'    => 'yunjiasu',
    '183.60.235.0/24'  => 'yunjiasu',
    '117.27.149.0/24'  => 'yunjiasu'
};

##### DRIVER #####

my $match = Net::IP::Match::Bin->new ($ranges);
my %check;
for (@ARGV)
{
   if (/^[0-9.]+$/)
   {
       ++ $check{$_};
   }
   else
   {
       # take away protocol specifications
       s|^.*://||; s|/.*||;

       my @addrs = gethostbyname ($_);
       %check = (%check, map { inet_ntoa ($_) => 1 } @addrs [ 4 .. $#addrs ]);
   }
}
       
printf ("%-15s  %s\n", $_, $match->match_ip ($_) // "Unknown") for keys %check;
