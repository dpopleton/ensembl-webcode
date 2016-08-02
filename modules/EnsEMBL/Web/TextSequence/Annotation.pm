package EnsEMBL::Web::TextSequence::Annotation;

use strict;
use warnings;

sub new {
  my ($proto,$p) = @_;

  my $class = ref($proto) || $proto;
  my $self = {
    phases => $p,
    view => undef,
  };
  bless $self,$class;
  return $self;
}

sub view { $_[0]->{'view'} = $_[1] if @_>1; return $_[0]->{'view'}; }
sub phases { $_[0]->{'phases'} = $_[1] if @_>1; return $_[0]->{'phases'}; }

sub name { return ref $_[0]; }
sub replaces { return undef; }

sub prepare_ropes {}

sub add_rope { return $_[0]->{'view'}->new_sequence; }

sub annotate_new { my $self = shift; return $self->annotate(@_); }

1;
