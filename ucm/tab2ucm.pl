# Combine TAB and original ucm into enhanced ucm
# .Tab + UCM -> UCM
#	.Tab   Unicode -> Encoding
#	.Ucm   Encoding -> Unicode, Original

&tab2ucm("gb2312-simp", "NJUC2GB.TAB", "euc-cn.ucm", "gb2312-add.dat");
&tab2ucm("big5-trad", "NJUC2B5.TAB", "cp950.ucm", "");

sub tab2ucm{
my ($ucmname, $tabfile, $ucmorg, $patchfile)=@_;
my $ucmdst="$ucmname.ucm";

#------------------Read TAB file
my $buf="";
sysopen R, $tabfile, 0;
sysread R, $buf, 65536*2;
close R;

#------------------Parse original UCM file
my %e2u={};
open RUCM, $ucmorg;
while(<RUCM>) {
	chomp;
	next if !( /^<U(....)> \\x(..)\\x(..)( \|(.)|)/ );
	$ucode_h=$1;
	$encode_low=$2;
	$encode_high=$3;
	$skip_flag=$5;
	$encode_h=$encode_low.$encode_high;
	#print "$_ = $ucode_h $encode_low $encode_high $encode_h $skip_flag\n";
	next if not($skip_flag==0 or $skip_flag==3 or $skip_flag eq '');
	$e2u{$encode_h}=$ucode_h;
}
close RUCM;

#------------------Parse TAB info, ignore duplicated encoding
for($i=0, $ucode=0; $i<length($buf); $i+=2, $ucode++){
	$ucode_h=sprintf("%04X", $ucode);
	$encode=substr($buf, $i, 2);
	$encode_low=ord(substr($encode, 0, 1));
	$encode_high=ord(substr($encode, 1, 1));
	$encode_h=sprintf("%02X%02X", $encode_low, $encode_high);
	next if $encode_h eq '3F3F';
	$e2u{$encode_h}=$ucode_h if $e2u{$encode_h} eq '';
}

#------------------Generate result as an enhanced ucm file
open W, ">$ucmdst";
use POSIX qw(strftime);
$curtime=localtime;
print W <<EOSTART;
# $ucmname.ucm - $curtime - Generated By Tab2Ucm.pl
<code_set_name> "$ucmname"
<mb_cur_min> 1
<mb_cur_max> 2
<subchar> \\x3F

CHARMAP
EOSTART

for($i=0, $ucode=0; $i<length($buf); $i+=2, $ucode++){
	$ucode_h=sprintf("%04X", $ucode);
	$encode=substr($buf, $i, 2);
	$encode_low=ord(substr($encode, 0, 1));
	$encode_high=ord(substr($encode, 1, 1));
	$encode_h=sprintf("%02X%02X", $encode_low, $encode_high);
	next if $encode_h eq '3F3F';
	$skip_flag=($e2u{$encode_h} eq $ucode_h) ? 0 : 1;
	printf W "<U%04X> \\x%02X", $ucode, $encode_low;
	printf W "\\x%02X", $encode_high if $encode_high>0;
	printf W " |%d", $skip_flag;
	print W " # $encode" if $encode_low>127 and $encode_high>=32;
	print W "\n";
}

#------------------Read Patch file
if($patchfile ne '') {
	open PATCH, $patchfile;
	while(<PATCH>) {
		chomp;
		next if $_ eq '';
		print W $_."\n";
	}
	close PATCH;
}

print W "END CHARMAP\n";
close W;
}