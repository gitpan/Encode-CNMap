use utf8;
use strict;
use Test::More tests => 17;
use File::Spec;
use File::Basename;

BEGIN { use_ok( 'Encode' ); use_ok( 'Encode::CNMap' ); }

my $path = dirname($0);
my ( $data_utf8, $data_gb, $data_gbk, $data_gbk2, $data_b5 );

&setenv; is( encode_to_b5( $data_utf8 ),  $data_b5,  'Big5 Encoding'   );
&setenv; is( encode_to_gb( $data_utf8 ),  $data_gb,  'GB2312 Encoding' );
&setenv; is( encode_to_gbk( $data_utf8 ), $data_gbk, 'GBK Encoding'    );

&setenv; is( simp_to_gb(  $data_gb  ), $data_gb,   'GB ->GB'  );
&setenv; is( simp_to_b5(  $data_gb  ), $data_b5,   'GB ->B5'  );

&setenv; is( simp_to_gb(  $data_gbk ), $data_gb,   'GBK->GB'  );
&setenv; is( simp_to_b5(  $data_gbk ), $data_b5,   'GBK->B5'  );

&setenv; is( trad_to_gb(  $data_b5  ), $data_gb,   'B5 ->GB'  );
&setenv; is( trad_to_gbk( $data_b5  ), $data_gbk2, 'B5 ->GBK' );

is(simp_to_gb(_('zhengqi.gbk')), _('zhengqi.gb'), 'GBK File->GB');
is(simp_to_b5(_('zhengqi.gbk')), _('zhengqi.b5'), 'GBK File->Big5');

is(simp_to_gb(_('zhengqi.gb')), _('zhengqi.gb'), 'GB File->GB');
is(simp_to_b5(_('zhengqi.gb')), _('zheng_gb.b5'), 'GB File->Big5');

is(trad_to_gb(_('zhengqi.b5')), _('zhengqi.gb'), 'Big5 File->GB');
is(trad_to_gbk(_('zhengqi.b5')), _('zhengqi.gbk'), 'Big5 File->GBK');

sub _ { local $/; open _, "<:raw", File::Spec->catfile($path, $_[0]); return <_> }
sub setenv {
	$data_utf8  = "中華中华";
	$data_gb    = Encode::encode( "gb2312", "中华中华" );
	$data_gbk   = Encode::encode( "gbk",    "中華中华" );
	$data_gbk2  = Encode::encode( "gbk",    "中華中華" );
	$data_b5    = Encode::encode( "big5",   "中華中華" );
}