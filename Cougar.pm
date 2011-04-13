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
      _FEATURES_PATH      => undef
    , _FEATURE_FILES_REF  => undef
    , _STEPS_PATH         => undef
  };
  return bless {};
}

#########
# Main  #
#########
sub run {
  my $self  = Cougar->new;
  print_version;
  
  $self->hash_params(\@ARGV);
  $self->review_params;
  $self->run_features;
}

#################
# SETUP SECTION #
#################
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
  return $self->_param( '_FEATURES_PATH', $path, './features' );
}

sub feature_files {
  my $self      = shift;
  my $file_ref  = shift;
  return $self->_param( '_FEATURE_FILES_REF', $file_ref, undef);
}

sub steps {
  my $self  = shift;
  my $path  = shift;
  return $self->_param( '_STEPS_PATH', $path, $self->features.'/steps' );
}


###################
# Main: Features #
##################
sub run_features {
  my $self  = shift;
  $self->collect_feature_files;
  foreach (@$self->feature_files) {
    my $feature = Feature->new;
    $feature->feature_file($_);
    $feature->open_feature;
    $feature->read_feature;
    $feature->run;
  }
}

sub collect_feature_files {
  my $self    = shift;
  my $files   = $self->list_features;
  
  my @features;
  foreach (@$files) {
    my $prep = $self->clean_and_prepend_feature($_);
    push(@features, $prep) if $self->is_feature_file($prep);
  }
  return $self->feature_files(\@features);
}

sub list_features {
  my $self  = shift;
  my $path  = $self->features;
  my @files = `ls $path`;
  return \@files;
}

sub is_feature_file {
  my $self  = shift;
  my $file  = shift;
  return $file =~ m/^.*\.feature$/;
}

sub clean_and_prepend_feature {
  my $self  = shift;
  my $file  = shift;
  $file = $self->clean_filename($file);
  return $self->prepend_features($file);
}

sub clean_filename {
  my $self  = shift;
  my $file  = shift;
  $file =~ m/^\s*(\S+)\s*$/;
  return $1;
}

sub prepend_features {
  my $self  = shift;
  my $file  = shift;
  return $self->features."/$file";
}


package Cougar::Feature;

use vars qw( $PARAMS $SCENARIO );

sub new {
  $PARAMS = {
      _FILE           => undef
    , _FH             => undef
    , _FH_ACCESSIBLE  => undef
    , _ACTIVE         => undef
    , _HEADER         => {
      _TEXT => undef
    }
  };
  return bless {};
}

sub trim {
  my $line  = shift;
  $line =~ s/^\s+//;
  $line =~ s/\s+$//;
  return $line;
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

sub feature_file {
  my $self  = shift;
  my $file  = shift;
  return $self->_param( '_FILE', $file, undef );
}

sub feature_file_handle {
  my $self  = shift;
  my $fh    = shift;
  return $self->_param( '_FH', $fh, undef );
}

sub is_accessible {
  my $self  = shift;
  my $open  = shift;
  return $self->_param( "_FH_ACCESSIBLE", $open, 0 );
}

sub open_feature {
  my $self  = shift;
  my $file  = shift;
  $self->feature_file($file) if $file;
  
  my $open = open(my $FH, "<", $self->feature_file);
  $self->feature_file_handle($FH);
  return $self->is_accessible($open)
}

sub read_feature {
  my $self  = shift;
  return 0 unless $self->is_accessible;
  
  my $fh = $self->feature_file_handle;
  my $section;
  while( <$fh> ) {
    my $line = trim($_);
    next if ($line eq '');
    
    if( $self->is_feature($line) ) {
      $section = 'push_feature';
    }
    
    if( $self->is_scenario($line) ) {
      $section = 'push_scenario'
    }
    
    next if $section eq 'push_scenario';
    $self->$section($line);
  }
  return $PARAMS;
}

sub is_feature {
  my $self  = shift;
  my $line  = shift;
  return ($line =~ m/^\s*Feature:.*$/i) ? 'feature' : undef;
}

sub is_scenario {
  my $self  = shift;
  my $line  = shift;
  return ($line =~ m/^\s*Scenario:.*$/i) ? 'scenario' : undef;
}

sub publish_feature {
  my $self  = shift;
  return $PARAMS->{_HEADER}->{_TEXT};
}

sub push_feature {
  my $self  = shift;
  my $line  = shift;
  $line = "$line\n";
  
  return $PARAMS->{_HEADER}->{_TEXT} = $line unless defined $PARAMS->{_HEADER}->{_TEXT};
  return $PARAMS->{_HEADER}->{_TEXT} .= "  $line";
}
