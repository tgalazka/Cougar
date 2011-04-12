use lib '../';
use Test::More;

###########
# Helpers #
###########
my $TMPDIR = './tmp';
sub cleanup {
  `rm -rf $TMPDIR`;
  
  1;
}


BEGIN { use_ok( Cougar ); }

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
  my $ignore  = "one.ignore";
  my $class = Cougar->new;
  $class->features($TMPDIR);
  
  subtest "'list_features': gets file names from supplied features dir", sub {
    `mkdir -p $TMPDIR`;
    map { `touch $_` } ( "$TMPDIR/$feature", "$TMPDIR/$ignore");
    
    my $features = $class->list_features;
    is( @$features[0], "$feature\n" );
    is( @$features[1], "$ignore\n" );
  };
  
  my $actual;
  is( $actual = $class->is_feature_file($feature), 1
  , "'is_feature_file': true('$actual') with file '$feature'");
  is( $actual = $class->is_feature_file($ignore), ''
  , "'is_feature_file': false('$actual') with file '$ignore'");
  
  is( $actual = $class->clean_filename(" $feature "), $feature
  , "'clean_filename': removed whitespaces fore and aft of text - '$actual'");
  is( $actual = $class->clean_filename("$feature\n"), $feature
  , "'clean_filename': removed newline aft of text - '$actual'");
  is( $actual = $class->clean_filename($feature), $feature
  , "'clean_filename': returns text if already clean - '$actual'");
  
  is( $actual = $class->prepend_features($feature), "$TMPDIR/$feature"
  , "'prepend_features': adds features dir to each filename - '$actual'");
  
  cleanup;
};

subtest "Collect feature files", sub {
  my @files = ("one.feature", "one.ignore");
  `mkdir -p $TMPDIR`;
  foreach (@files) {
    my $tmp = "$TMPDIR/$_";
    `touch $tmp`;
  }
  
  my $class = Cougar->new;
  $class->features($TMPDIR);
  my $features = $class->collect_feature_files;
  is( @$features[0], "$TMPDIR/one.feature"
  , "Collected only files with '.feature' extension");
  cleanup;
};

cleanup;
done_testing();