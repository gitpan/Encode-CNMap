use strict;
use Test::More tests => 17;
use File::Spec;
use File::Basename;

my $path = dirname($0);

use_ok('Encode');
use_ok('Encode::CNMap');

my $data;
$data="中華";	is(simp_to_gb($data), '中华', 'GBK->GB');
$data="中華";	is(simp_to_b5($data), 'い地', 'GBK->B5');

$data="中华";	is(simp_to_gb($data), '中华', 'GB->GB');
$data="中华";	is(simp_to_b5($data), 'い地', 'GB->B5');

$data="い地";	is(trad_to_gb($data), '中华', 'Big5->GB');
$data="い地";	is(trad_to_gbk($data), '中華', 'Big5->GBK');

$data=Encode::decode("gbk", "中華中华");
is(encode_to_b5($data), "い地い地", 'Big5 Encoding');
is(encode_to_gb($data), "中华中华", 'GB2312 Encoding');
is(encode_to_gbk($data), "中華中华", 'GBK Encoding');

is(simp_to_gb(_('zhengqi.gbk')), _('zhengqi.gb'), 'GBK File->GB');
is(simp_to_b5(_('zhengqi.gbk')), _('zhengqi.b5'), 'GBK File->Big5');

is(simp_to_gb(_('zhengqi.gb')), _('zhengqi.gb'), 'GB File->GB');
is(simp_to_b5(_('zhengqi.gb')), _('zheng_gb.b5'), 'GB File->Big5');

is(trad_to_gb(_('zhengqi.b5')), _('zhengqi.gb'), 'Big5 File->GB');
is(trad_to_gbk(_('zhengqi.b5')), _('zhengqi.gbk'), 'Big5 File->GBK');

sub _ { local $/; open _, File::Spec->catfile($path, $_[0]); return <_> }