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

subtest "Access Scenario class and can create a new one", sub {
  my $class = Cougar::Scenario->new;
  isa_ok( $class, Cougar::Scenario );
};

subtest "Working with a Scenario headline", sub {
  my $class = Cougar::Scenario->new;
  
  is($class->headline, undef,
    "Default headline is undefined");
  is($class->headline("Headline"), "Headline",
    "Can set a new headline and have it return");
  is($class->headline, "Headline",
    "Can retrieve the set headline.")
};

subtest "Setting scenario steps", sub {
  my $class = Cougar::Scenario->new;
  
  is($class->add_step("    Given a step"), 1,
    "Store a step and return the resultant size of the step array.");
    
  my $steps = <<STEPS;
  Scenario: This is a headline.
    Given a step
    When I get another
    Then there are three
STEPS

  $class->headline("  Scenario: This is a headline.");
  $class->add_step("    When I get another");
  is($class->add_step("    Then there are three"), 3,
    "Has a total of three steps");
  is($class->publish_scenario, $steps, 
    "Has entire scenario stored intact.");
};

done_testing();