use strict;
use Test::More tests => 17;
use File::Spec;
use File::Basename;

my $path = dirname($0);

use_ok('Encode');
use_ok('Encode::CNMap');

my $data;
$data="���A";	is(simp_to_gb($data), '�л�', 'GBK->GB');
$data="���A";	is(simp_to_b5($data), '����', 'GBK->B5');

$data="�л�";	is(simp_to_gb($data), '�л�', 'GB->GB');
$data="�л�";	is(simp_to_b5($data), '����', 'GB->B5');

$data="����";	is(trad_to_gb($data), '�л�', 'Big5->GB');
$data="����";	is(trad_to_gbk($data), '���A', 'Big5->GBK');

$data=Encode::decode("gbk", "���A�л�");
is(encode_to_b5($data), "���ؤ���", 'Big5 Encoding');
is(encode_to_gb($data), "�л��л�", 'GB2312 Encoding');
is(encode_to_gbk($data), "���A�л�", 'GBK Encoding');

is(simp_to_gb(_('zhengqi.gbk')), _('zhengqi.gb'), 'GBK File->GB');
is(simp_to_b5(_('zhengqi.gbk')), _('zhengqi.b5'), 'GBK File->Big5');

is(simp_to_gb(_('zhengqi.gb')), _('zhengqi.gb'), 'GB File->GB');
is(simp_to_b5(_('zhengqi.gb')), _('zheng_gb.b5'), 'GB File->Big5');

is(trad_to_gb(_('zhengqi.b5')), _('zhengqi.gb'), 'Big5 File->GB');
is(trad_to_gbk(_('zhengqi.b5')), _('zhengqi.gbk'), 'Big5 File->GBK');

sub _ { local $/; open _, File::Spec->catfile($path, $_[0]); return <_> }