use lib '../';
use Test::More;

BEGIN { use_ok( Cougar ); }

ok( 0.0 == Cougar->version, "Get current Cougar version." );

subtest "Split option parameter", sub {
  my $option = "key=val";
  my( $key, $val ) = Cougar->split_option($option);
  ok( $key eq "key", "Got key." ) or diag( "Key = '$key'" );
  ok( $val eq "val", "Got value." ) or diag( "Val = '$val'" );
};

done_testing();