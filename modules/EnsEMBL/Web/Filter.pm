package EnsEMBL::Web::Filter;

### Parent for filters that control access to web pages.
 
### Note that in child modules you *must* set one or more error codes
### and corresponding messages, but it is not always necessary to set 
### a redirect URL as this will default to the originating page

use strict;

use base qw(EnsEMBL::Web::Root);

sub new {
  my ($class, $data) = @_;
  my $self = $data ? {%$data} : {};
  
  bless $self, $class;
  
  $self->messages = {}; # Not sure why this is needed
  $self->init;
  
  return $self;
}

sub init {} # implemented in child modules

sub object     :lvalue { $_[0]->{'object'};     }
sub redirect   :lvalue { $_[0]->{'redirect'};   }
sub error_code :lvalue { $_[0]->{'error_code'}; }
sub messages   :lvalue { $_[0]->{'messages'};   }
sub exceptions :lvalue { $_[0]->{'exceptions'}; }

# Function to catch any errors and set the code to be used in the URL
# N.B. this is a stub: set your error codes in the child module
sub catch {
  my $self = shift;
  warn "!!! No error codes set in filter $self";
}

# Returns the name of the filter, i.e. the final section of the namespace
# N.B. because we do not pass the full filter namespace, filters are not pluggable,
# though they can be overridden in the normal Perl way 
sub name {
  my $self = shift;
  my @namespace = split '::', ref $self;
  return $namespace[-1];
}

# Returns an error message, based on the filter_code parameter
# Note that we set a default message in case there is no match. 
# The default message has to be very vague because filters are used for 
# data validation as well as access control. Ideally the user should never 
# see this message - if it appears on a web page, you know you are 
# missing a message in your filter!
sub error_message {
  my ($self, $code) = @_;
  my $message;
  
  # Check for temporary messages stored in session
  # Or return a preset message
  if ($code) {
    $message = $self->messages->{$code};
  } else {
    $message = 'Sorry, validation failed.';
  }
  
  return $message;
}

# Defaults to returning the originating URL, unless already set 
# within the individual Filter's catch method.
sub redirect_url {
  my $self = shift;
  my $url = $self->object->species_path . $self->redirect;
  my @ok_params;
  
  if (!$url) {
    $url = '/' . $self->type . '/' . $self->action;
    
    foreach my $p ($self->object->input_param) {
      push @ok_params, "$p=" . $self->object->param($p);
    }
    
    $url .= '?' . join ';', @ok_params if @ok_params;
  }
  
  return $url;
}

1;
