use lib '../';
use Test::More;

BEGIN { use_ok( Cougar ); }

subtest "Method 'features' behavior", sub {
  my $return = '';
  ok( ($return = Cougar->features) eq './features', "Got default setting." ) or
    diag( "Got: '$return'" );
  ok( ($return = Cougar->features('/some/path')) eq '/some/path', "Set a custom path." ) or
    diag( "Got: '$return'" );
  ok( ($return = Cougar->features) eq '/some/path', "Custom path persisted." ) or
    diag( "Got: '$return'" );
};

subtest "Set feature parameter from command line", sub {
  my $key = '--features';
  my $val = '/some/file/path';
  Cougar->validate_param($key, $val);
  ok( Cougar->features eq $val );
};

done_testing();