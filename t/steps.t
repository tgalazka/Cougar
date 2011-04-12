use lib '../';
use Test::More;

BEGIN { use_ok( Cougar ); }

subtest "Method 'steps' behavior", sub {
  my $return  = '';
  
  ok( ($return = Cougar->steps) eq "./features/steps", "Got default setting." ) or
    diag( "Got: '$return'" );
  ok( ($return = Cougar->steps('/some/path')) eq '/some/path', "Set a custom path." ) or
    diag( "Got: '$return'" );
  ok( ($return = Cougar->steps) eq '/some/path', "Custom path persisted." ) or
    diag( "Got: '$return'" );
};

subtest "Set step parameter from command line", sub {
  my $key = '--steps';
  my $val = '/some/file/path';
  Cougar->validate_param($key, $val);
  ok( Cougar->steps eq $val );
};

done_testing;