use lib '../';
use Test::More;

###########
# Helpers #
###########
use vars qw( $FIXTURES $FEATURE );
$FIXTURES  = './fixtures';
$FEATURE   = "$FIXTURES/one.feature";


###################
# Testing Begins  #
###################
BEGIN { use_ok( Cougar ); }

subtest "Access Feature class and can create a new one", sub {
  my $class = Cougar::Feature->new;
  isa_ok( $class, Cougar::Feature );
};

subtest "Manage the file that backs the Feature class", sub {
  my $class = Cougar::Feature->new;
  
  is( $class->feature_file, undef
  , "Default 'feature_file' returns 'undef'" );
  is( $class->feature_file($FEATURE), $FEATURE
  , "Uses 'feature_file' to set the qualified file path" );
  
  is( $class->is_accessible, 0
  , "Feature inaccessible" );
  is( $class->open_feature, 1
  , "Open the feature file backing the class (preset)." );
  is( $class->is_accessible, 1
  , "Once file is open, feature is accessible." );
  is( $class->open_feature($FEATURE), 1
  , "Open the feature file backing the class (supply file)." );
  is( $class->is_accessible, 1
  , "Once file is open, feature is accessible." );
};

subtest "Test for feature block", sub {
  my $class = Cougar::Feature->new;
  
  is( $class->is_feature("Feature: Stuff"), 'feature'
  , "Identify the feature headline: proper case" );
  is( $class->is_feature("feATurE: StuFf"), 'feature'
  , "Identify the feature headline: case insensitive" );
  is( $class->is_feature("Stuff"), undef
  , "Not a feature headline." );
};

subtest "Test for scenario block", sub {
  my $class = Cougar::Feature->new;
  
  is( $class->is_scenario("Scenario: Stuff"), 'scenario'
  , "Identify the scenario: proper case" );
  is( $class->is_scenario("scENaRio: StuFf"), 'scenario'
  , "Identify the scenario: case insensitive" );
  is( $class->is_scenario("Stuff"), undef
  , "Not a scenario section." );
  is( $class->is_scenario("feature: Stuff"), undef
  , "Not a scenario section." );
};

subtest "Read a feature file", sub {
  my $class = Cougar::Feature->new;
  $class->open_feature($FEATURE);
  $class->read_feature; 
  
  my $headline = <<HEADLINE;
Feature: Run cucumber in Perl
  In order to BDD Perl code
  a user should be able
  to use Cougar.
HEADLINE
  is( $class->publish_feature, $headline
  , "Read in the feature description from the file." );
  
};

subtest "Manipulating Scenarios in a Feature", sub {
  my $class = Cougar::Feature->new;
  
  is($class->scenario, undef,
    "Returns the default if no scenario.");
  my $first = Cougar::Scenario->new;
  $first->headline("New Headline");
  $class->scenario($first);
  is($class->scenario->headline, "New Headline",
    "Can retrieve the current scenario.");
  
  isa_ok($class->new_scenario, Cougar::Scenario,
    "Feature can create new Scenario object.");
  is($class->new_scenario->headline, undef,
    "Returned scenario has no headline");
    
  my $scenario = $class->new_scenario("Newest Headline");
  isa_ok($scenario, Cougar::Scenario,
    "Sent a headline with the creation of a scenario.");
  is($scenario->headline, "Newest Headline",
    "The returned scenario has the headline designated.");
  
};

done_testing();