#!/usr/local/bin/perl
#use ExtUtils::testlib;
$VERSION = '0.12';

=head1 NAME

cnmap.pl - Traditional <-> Simplified Chinese Converter

=head1 SYNOPSIS

B<cnmap.pl> C<-command> [ I<inputfile> ...] > I<outputfile>

=head1 USAGE

    % cnmap.pl -s2b5 gbk.txt > big5.txt
    % cnmap.pl -s2gb gbk.txt > gb.txt
    % cnmap.pl -t2gb big5.txt > gb.txt
    % cnmap.pl -t2gbk big5.txt big5-2.txt > gbk.txt

=head1 DESCRIPTION

The B<cnmap.pl> utility reads files sequentially, converts them from
Traditional to Simplified Chinese or Simplified to Traditional Chinese
according to command switch, then writes them to the standard output.
The I<inputfile> arguments are processed in command-line order. if
I<inputfile> is a single dash (C<->) or absent, this program reads
from the standard input.

The C<-s2b5> switch: Mixed GB2312/GBK -> Traditional Big5.

The C<-s2gb> switch: Mixed GB2312/GBK -> Simplified GB2312.

The C<-t2gb> switch: Traditional Big5 -> Simplified GB2312.

The C<-t2gbk> switch: Traditional Big5 -> Mixed GBK.

=cut

use strict;
use Getopt::Std;
my %opts;
BEGIN {
    getopts('-helpst2gbk5', \%opts);
    if ($opts{h}) { system("perldoc", $0); exit }
    $SIG{__WARN__} = sub {};
}

use Encode::CNMap;
my $func=*trad_to_gb;
$func=*simp_to_b5 if $opts{5};
$func=*simp_to_gb if $opts{s} and $opts{g};
$func=*trad_to_gbk if $opts{t} and $opts{k};

binmode(STDIN);	binmode(STDOUT);
while (<>) {
	print &$func($_);
}

__END__

=head1 SEE ALSO

L<Encode::CNMap>, L<cnmapdir.pl>, L<Encode::HanConvert>, L<Encode>

=head1 AUTHORS

Qing-Jie Zhou E<lt>qjzhou@hotmail.comE<gt>

=cut
