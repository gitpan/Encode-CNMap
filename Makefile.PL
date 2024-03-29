#
# This file is auto-generated by:
# enc2xs version 1.31
# Wed Jan 29 21:43:10 2003
#
use 5.008;
use strict;
use ExtUtils::MakeMaker;
use Config;

# Please edit the following to the taste!
my $name = 'CNMap';
my %tables = (
	     CNMap_t   => [ 'ucm/gb2312-simp.ucm','ucm/big5-trad.ucm' ],
	     );

#### DO NOT EDIT BEYOND THIS POINT!
require File::Spec;
my ($enc2xs, $encode_h) = ();
PATHLOOP:
for my $d (@Config{qw/bin sitebin vendorbin/},
	   (split /$Config{path_sep}/o, $ENV{PATH})){
    for my $f (qw/enc2xs enc2xs5.7.3 enc2xs.bat/){
        my $path = File::Spec->catfile($d, $f);
        -r $path and $enc2xs = $path and last PATHLOOP;
    }
}
$enc2xs or die "enc2xs not found!";
print "enc2xs is $enc2xs\n";
my %encode_h = ();
for my $d (@INC){
    my $dir = File::Spec->catfile($d, "Encode");
    my $file =  File::Spec->catfile($dir, "encode.h");
    -f $file and $encode_h{$dir} = -M $file;
}
%encode_h or die "encode.h not found!";
# find the latest one
($encode_h) = sort {$encode_h{$b} <=> $encode_h{$a}} keys %encode_h;
print "encode.h is at $encode_h\n";

WriteMakefile(
		  EXE_FILES     => [ <bin/cnmap bin/cnmapdir bin/cnmapwx> ],
              INC		=> "-I$encode_h",
	      NAME		=> 'Encode::'.$name,
	      VERSION_FROM	=> "$name.pm",
	      OBJECT		=> '$(O_FILES)',
	      'dist'		=> {
		  COMPRESS	=> 'gzip -9f',
		  SUFFIX	=> 'gz',
		  DIST_DEFAULT => 'all tardist',
	      },
	      MAN3PODS	=> {},
	      NO_META	=> 1,
	      PREREQ_PM => {
			    'Encode'     => "1.41",
                           },
	      # OS 390 winges about line numbers > 64K ???
	      XSOPT => '-nolinenumbers',
          ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      		(ABSTRACT_FROM => 'CNMap.pm', # retrieve abstract from module
       		AUTHOR     => 'Qing-Jie Zhou <qjzhou@hotmail.com>') : ()),
	      );

package MY;

sub post_initialize
{
    my ($self) = @_;
    my %o;
    my $x = $self->{'OBJ_EXT'};
    # Add the table O_FILES
    foreach my $e (keys %tables)
    {
	$o{$e.$x} = 1;
    }
    $o{"$name$x"} = 1;
    $self->{'O_FILES'} = [sort keys %o];
    my @files = ("$name.xs");
    $self->{'C'} = ["$name.c"];
    # The next two lines to make MacPerl Happy -- dankogai via pudge
    $self->{SOURCE} .= " $name.c"
        if $^O eq 'MacOS' && $self->{SOURCE} !~ /\b$name\.c\b/;
    # $self->{'H'} = [$self->catfile($self->updir,'encode.h')];
    my %xs;
    foreach my $table (keys %tables) {
	push (@{$self->{'C'}},"$table.c");
	# Do NOT add $table.h etc. to H_FILES unless we own up as to how they
	# get built.
	foreach my $ext (qw($(OBJ_EXT) .c .h .exh .fnm)) {
	    push (@files,$table.$ext);
	}
    }
    $self->{'XS'} = { "$name.xs" => "$name.c" };
    $self->{'clean'}{'FILES'} .= join(' ',@files);
    open(XS,">$name.xs") || die "Cannot open $name.xs:$!";
    print XS <<'END';
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#define U8 U8
#include "encode.h"
END
    foreach my $table (keys %tables) {
	print XS qq[#include "${table}.h"\n];
    }
    print XS <<"END";

static void
Encode_XSEncoding(pTHX_ encode_t *enc)
{
 dSP;
 HV *stash = gv_stashpv("Encode::XS", TRUE);
 SV *sv    = sv_bless(newRV_noinc(newSViv(PTR2IV(enc))),stash);
 int i = 0;
 PUSHMARK(sp);
 XPUSHs(sv);
 while (enc->name[i])
  {
   const char *name = enc->name[i++];
   XPUSHs(sv_2mortal(newSVpvn(name,strlen(name))));
  }
 PUTBACK;
 call_pv("Encode::define_encoding",G_DISCARD);
 SvREFCNT_dec(sv);
}

MODULE = Encode::$name	PACKAGE = Encode::$name
PROTOTYPES: DISABLE
BOOT:
{
END
    foreach my $table (keys %tables) {
	print XS qq[#include "${table}.exh"\n];
    }
    print XS "}\n";
    close(XS);
    return "# Built $name.xs\n\n";
}

sub postamble
{
    my $self = shift;
    my $dir  = "."; # $self->catdir('Encode');
    my $str  = "# $name\$(OBJ_EXT) depends on .h and .exh files not .c files - but all written by enc2xs\n";
    $str    .= "$name.c : $name.xs ";
    foreach my $table (keys %tables)
    {
	$str .= " $table.c";
    }
    $str .= "\n\n";
    $str .= "$name\$(OBJ_EXT) : $name.c\n\n";

    foreach my $table (keys %tables)
    {
	my $numlines = 1;
	my $lengthsofar = length($str);
	my $continuator = '';
	$str .= "$table.c : Makefile.PL";
	foreach my $file (@{$tables{$table}})
	{
	    $str .= $continuator.' '.$self->catfile($dir,$file);
	    if ( length($str)-$lengthsofar > 128*$numlines )
	    {
		$continuator .= " \\\n\t";
		$numlines++;
	    } else {
		$continuator = '';
	    }
	}
	my $plib   = $self->{PERL_CORE} ? '"-I$(PERL_LIB)"' : '';
	my $ucopts = '-"Q"';
	$str .=
	    qq{\n\t\$(PERL) $plib $enc2xs $ucopts -o \$\@ -f $table.fnm\n\n};
	open (FILELIST, ">$table.fnm")
	    || die "Could not open $table.fnm: $!";
	foreach my $file (@{$tables{$table}})
	{
	    print FILELIST $self->catfile($dir,$file) . "\n";
	}
	close(FILELIST);
    }
    return $str;
}

