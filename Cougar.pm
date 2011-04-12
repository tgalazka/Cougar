package Cougar;

use strict;

use vars qw( $VERSION $PARAMS);
$VERSION = 0.0;

run() unless caller;

sub version {
  return $VERSION;
}

sub print_version {
  print "Cougar Version: ".version."\n";
}

sub print_help {
  print <<TEXT;
Usage: perl Cougar.pm (OPTIONAL [--features|--steps]=value )
  --features  :   Path to features directory.
  --steps     :   Path to steps directory.
  --help      :   Print this message and exit.
TEXT
}

sub croak {
  my $msg = shift;
  die( $msg );
}

sub new {
  $PARAMS = {
      _FEATURES_PATH => undef
    , _STEPS_PATH    => undef
  };
  return bless {};
}

sub run {
  my $self  = Cougar->new;
  print_version;
  
  $self->hash_params(\@ARGV);
  $self->review_params;
}

sub review_params {
  my $self  = shift;
  print "Running with the following paths:\n";
  print "\tFeatures path: '".$self->features."'\n";
  print "\t   Steps path: '".$self->steps."'\n";
}

sub hash_params {
  my $self  = shift;
  my $argv  = shift;
  foreach (@$argv) {
    my( $key, $value ) = $self->split_option($_);
    $self->validate_param($key, $value);
  }
}

sub split_option {
  my $self  = shift;
  my $str   = shift;
  return split('=', $str);
}

sub validate_param {
  my $self  = shift;
  my $key   = shift;
  my $val   = shift;
  
  SWITCH: {
    $key eq '--features'  && do { $self->features($val);  last SWITCH; };
    $key eq '--steps'     && do { $self->steps($val);     last SWITCH; };
    $key eq '--help'      && do { print_help; exit 1;     last SWITCH; };
    croak( "Invalid option '$key' containing value '$val'" );
  }
}

sub _param {
  my $self    = shift;
  my $param   = shift;
  my $value   = shift;
  my $default = shift;
  
  $PARAMS->{$param} = $value if defined $value;
  return $PARAMS->{$param} if defined $PARAMS->{$param};
  return $PARAMS->{$param} = ( (defined $value) ? $value : $default );
}

sub features {
  my $self  = shift;
  my $path  = shift;
  return $self->_param( '_FEATURES_PATH', $path, './features' )
}

sub steps {
  my $self  = shift;
  my $path  = shift;
  return $self->_param( '_STEPS_PATH', $path, $self->features.'/steps' )
}


