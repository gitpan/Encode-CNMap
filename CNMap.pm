package Encode::CNMap;
use vars qw/$VERSION @EXPORT @EXPORT_OK/;

$VERSION = "0.13";
@EXPORT = qw(
    simp_to_b5 simp_to_gb trad_to_gb trad_to_gbk
    encode_to_b5 encode_to_gb encode_to_gbk
);
@EXPORT_OK = @EXPORT;
use base 'Exporter';
 
use Encode;
use XSLoader;
XSLoader::load(__PACKAGE__,$VERSION);

sub simp_to_b5($) {
	Encode::from_to($_[0], 'gbk', 'big5-trad');
	return $_[0];
}

sub simp_to_gb($) {
	Encode::from_to($_[0], 'gbk', 'gb2312-simp');
	return $_[0];
}

sub trad_to_gb($) {
	Encode::from_to($_[0], 'big5-trad', 'gb2312-simp');
	return $_[0];
}

sub trad_to_gbk($) {
	Encode::from_to($_[0], 'big5-trad', 'gbk');
	return $_[0];
}

sub encode_to_b5($) {
	return Encode::encode("big5-trad", $_[0]);
}

sub encode_to_gb($) {
	return Encode::encode("gb2312-simp", $_[0]);
}

sub encode_to_gbk($) {
	return Encode::encode("gbk", $_[0]);
}

1;
__END__

=head1 NAME
 
Encode::CNMap - enhanced Chinese encodings with Simplified-Traditional auto-mapping
 
=head1 SYNOPSIS

	use Encode;
	use Encode::CNMap;

	# Simplified encoding (GBK/GB) -> Big5 encoding い地い地
	$data="中華中华";
	printf "[Mixed GBK] %s", $data;
	printf " -> [Traditional Big5] %s\n", simp_to_b5($data);

	# Simplified encoding (GBK/GB) -> GB2312 encoding 中华中华
	$data="中華中华";
	printf "[Mixed GBK] %s", $data;
	printf " -> [Simplified GB2312] %s\n", simp_to_gb($data);
	
	# Traditional encoding (Big5) -> GB2312 encoding 中华中华
	$data="い地い地";
	printf "[Traditional Big5] %s", $data;
	printf " -> [Simplified GB2312] %s\n", trad_to_gb($data);

	# Traditional encoding (Big5) -> GBK encoding 中華中華
	$data="い地い地";
	printf "[Traditional Big5] %s", $data;
	printf " -> [Mixed GBK] %s\n", trad_to_gbk($data);

	# Encoding with Simplified<->Traditional Auto-Converting
	$data=Encode::decode("gbk", "中華中华");
	printf "Traditional Big5: %s\n", encode_to_b5($data);
	printf "Simplified GB2312: %s\n", encode_to_gb($data);
	printf "Mixed GBK: %s\n", encode_to_gbk($data);

=head1 DESCRIPTION

This module implements China-based Chinese charset encodings.
Encodings supported are as follows.

  Canonical   Alias     Description
  --------------------------------------------------------------------
  gb2312-simp           Enhanced GB2312 simplified chinese encoding
  big5-trad             Enhanced Big5 traditional chinese encoding
  --------------------------------------------------------------------

To find how to use this module in detail, see L<Encode>.

=head1 SEE ALSO

L<cnmap.pl>, L<cnmapdir.pl>, L<Encode>, L<Encode::CN>, L<Encode::HanConvert>, L<Encode::HanExtra>

=head1 AUTHORS

Qing-Jie Zhou E<lt>qjzhou@hotmail.comE<gt>

=cut
