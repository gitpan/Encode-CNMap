#!/usr/local/bin/perl
#use ExtUtils::testlib;
$VERSION = '0.12';

=head1 NAME

cnmapdir.pl - Traditional <-> Simplified Chinese Converter

=head1 SYNOPSIS

B<cnmapdir.pl> C<-command> I<inputdir/file> I<outputdir/file>

=head1 USAGE

    % cnmapdir.pl -s2b5 gbkdir big5dir
    % cnmapdir.pl -s2gb gbkdir gbdir
    % cnmapdir.pl -t2gb big5dir gbdir
    % cnmapdir.pl -t2gbk big5dir gbkdir

=head1 DESCRIPTION

The B<cnmapdir.pl> utility reads all files recursively under inputdir,
converts from Traditional to Simplified Chinese or Simplified to
Traditional Chinese according to command switch, then writes them to
the outputdir.

If outputdir is missing, then /out is assumped. If outputdir is not
existed, it will be created automatically. If inputdir is a file, it
will be converted to outputfile.

The C<-s2b5> switch: Mixed GB2312/GBK -> Traditional Big5.

The C<-s2gb> switch: Mixed GB2312/GBK -> Simplified GB2312.

The C<-t2gb> switch: Traditional Big5 -> Simplified GB2312.

The C<-t2gbk> switch: Traditional Big5 -> Mixed GBK.

=cut

use File::Spec;
use Encode::CNMap;
use Getopt::Std;
my %opts;
BEGIN {
    getopts('-helpst2gbk5', \%opts);
    if ($opts{h}) { system("perldoc", $0); exit }
    $SIG{__WARN__} = sub {};
}

my ($dirin, $dirout);
$dirin=$ARGV[0];
$dirin=File::Spec->curdir() if $dirin eq '';
$dirout=$ARGV[1];
$dirout='/out' if $dirout eq '';

# Shared func and buf
our $func=*trad_to_gb;
$func=*simp_to_b5 if $opts{5};
$func=*simp_to_gb if $opts{s} and $opts{g};
$func=*trad_to_gbk if $opts{t} and $opts{k};
our $buf="";

&ProcessSub("", $dirin, $dirout);

sub ProcessSub($$$) {
	my ($space, $fin, $fout)=@_;

	if(-f $fin) {	# File Processing
		print "$space   $fin -> $fout ... ";
		open R, $fin or goto read_err;
		binmode(R);
		sysread R, $buf, 16*1024*1024 or goto read_err;
		close R or goto read_err;
		&$func($buf);
		print "Overwriting " if -f $fout;
		open W, ">$fout" or goto write_err;
		binmode(W);
		syswrite W, $buf or goto write_err;
		close W or print or goto write_err;
		print "OK\n";
		return;
		
		read_err:
		print "Read Fail!\n";
		return;
		
		write_err:
		print "Write Fail!\n";
		return;
	}

	if(-d $fin) {	# Dir Processing
		print "$space [$fin -> $fout] ... ";
		
		my (@dir, $filename, $filein, $fileout);
		opendir(DIR, $fin) or goto dir_err;
		@dir=readdir(DIR) or goto dir_err;
		closedir DIR or goto dir_err;

		if( not(-d $fout) ) {
			print "Mkdir ";
			mkdir $fout or goto mkdir_err;
		}
		
		print "OK\n";
		foreach $filename (@dir) {
			&ProcessSub($space."  "
				, File::Spec->catfile($fin, $filename)
				, File::Spec->catfile($fout, $filename)
			) if not($filename=~/^\./);
		}
		return;
		
		dir_err:
		print "Read Fail!\n";
		return;
		
		mkdir_err:
		print "Fail!\n";
		return;
	}
	
	print "$space Unkown $fin ... Skipped\n";
}

__END__

=head1 SEE ALSO

L<Encode::CNMap>, L<cnmap.pl>, L<Encode::HanConvert>, L<Encode>

=head1 AUTHORS

Qing-Jie Zhou E<lt>qjzhou@hotmail.comE<gt>

=cut
