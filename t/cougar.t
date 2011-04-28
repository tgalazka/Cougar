use lib '../';
use Test::More;

###########
# Helpers #
###########
use vars qw( $FIXTURES );
$FIXTURES  = './fixtures';

###################
# Testing Begins  #
###################
BEGIN { use_ok( Cougar ); }

subtest "Access Cougar class and can create a new one", sub {
  my $class = Cougar->new;
  isa_ok( $class, Cougar );
};

subtest "Split option parameter", sub {
  my $option = "key=val";
  my( $key, $val ) = Cougar->split_option($option);
  ok( $key eq "key", "Got key." ) or diag( "Key = '$key'" );
  ok( $val eq "val", "Got value." ) or diag( "Val = '$val'" );
};

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

subtest "Method 'features' behavior", sub {
  my $class = Cougar->new;
  my $return = '';
  is( ($return = $class->features), './features', "Got default setting." );
  is( ($return = $class->features('/some/path')), '/some/path', "Set a custom path." );
  is( ($return = $class->features), '/some/path', "Custom path persisted." );
};

subtest "Set feature parameter from command line", sub {
  my $key = '--features';
  my $val = '/some/file/path';
  my $class = Cougar->new;
  my $return = '';
  $class->validate_param($key, $val);
  is( ($return = $class->features), $val, "Feature command line param set properly." );
};

subtest "Feature file collection helper methods", sub {
  my $feature = "one.feature";
  my $ignore  = "ignore.faux";
  my $class = Cougar->new;
  $class->features($FIXTURES);
  
  subtest "'list_features': gets file names from supplied features dir", sub {
    my $features = $class->list_features;
    is( @$features[0], "$ignore\n" );
    is( @$features[1], "$feature\n" );
  };
  
  my $actual;
  is( $actual = $class->is_feature_file($feature), 1
  , "'is_feature_file': true('$actual') with file '$feature'");
  is( $actual = $class->is_feature_file($ignore), ''
  , "'is_feature_file': false('$actual') with file '$ignore'");
  
  is( $actual = $class->trim(" $feature "), $feature
  , "'trim': removed whitespaces fore and aft of text - '$actual'");
  is( $actual = $class->trim("$feature\n"), $feature
  , "'trim': removed newline aft of text - '$actual'");
  is( $actual = $class->trim($feature), $feature
  , "'trim': returns text if already clean - '$actual'");
  
  is( $actual = $class->prepend_features($feature), "$FIXTURES/$feature"
  , "'prepend_features': adds features dir to each filename - '$actual'");
};

subtest "Collect feature files", sub {
  my $class = Cougar->new;
  $class->features($FIXTURES);
  
  my $features = $class->collect_feature_files;
  is( @$features[0], "$FIXTURES/one.feature"
  , "Collected only files with '.feature' extension");
};

done_testing();

print "\n\nRunning a functional test.\n";
my $class = Cougar->new;
$class->features($FIXTURES);
$class->run_features;