package Bio::EnsEMBL::GlyphSet::tigr_0_5_transcript;
use strict;
use vars qw(@ISA);
use Bio::EnsEMBL::GlyphSet_transcript;
@ISA = qw(Bio::EnsEMBL::GlyphSet_transcript);

sub my_label {
    return 'TIGR trans.';
}

sub colours {
    my $self = shift;
    my $Config = $self->{'config'}->get('tigr_0_5_transcript','colours');
}

sub colour {
  my ($self, $gene, $transcript, $colours, %highlights) = @_;
   
  my $highlight = undef;
  my $colour = $colours->{'tigr_0_5'}[0];
  if(exists $highlights{lc($transcript->stable_id)}) {
    $highlight = $colours->{'superhi'};
  } elsif(exists $highlights{lc($transcript->external_name)}) {
    $highlight = $colours->{'superhi'};
  } elsif(exists $highlights{lc($gene->stable_id)}) {
    $highlight = $colours->{'hi'};
  }

  return ($colour, $highlight); 
}

sub gene_colour {
  my ($self, $gene, $colours, %highlights) = @_;
  my $highlight = undef;
  my $colour = $colours->{lc($gene->type())}[0];

  if(exists $highlights{lc($gene->external_name)}) {
    $highlight = $colours->{'superhi'};
  } elsif(exists $highlights{lc($gene->stable_id)}) {
    $highlight = $colours->{'hi'};
  }
  return ($colour, $highlight);
}

sub href {
  my ($self, $gene, $transcript, %highlights) = @_;
  my $gid = $gene->stable_id();
  my $tid = $transcript->stable_id();

  return ( $self->{'config'}->get('tigr_0_5_transcript','_href_only') eq '#tid' && exists $highlights{lc($gene->stable_id())} ) ?
        "#$tid" : 
        qq(/@{[$self->{container}{_config_file_name_}]}/geneview?gene=$gid);

}

sub gene_href {
  my ($self, $gene, %highlights) = @_;
  my $gid = $gene->stable_id();
  return ( $self->{'config'}->get('tigr_0_5_transcript','_href_only') eq '#gid' && exists $highlights{lc($gid)} ) ?
    "#$gid" : qq(/@{[$self->{container}{_config_file_name_}]}/geneview?gene=$gid);
}


sub zmenu {
  my ($self, $gene, $transcript) = @_;
  my $id = '';

  my $tid = $transcript->stable_id();
  my $pid = $transcript->translation ? $transcript->translation->stable_id() : undef;
  my $gid = $gene->stable_id();
  
  my $zmenu = {
    'caption'         => "TIGR Gene",
    "01:Gene:$gid"    => "/@{[$self->{container}{_config_file_name_}]}/geneview?gene=$gid",
    "02:Transcr:$tid" => "/@{[$self->{container}{_config_file_name_}]}/transview?transcript=$tid",                	
    '04:Export cDNA'  => "/@{[$self->{container}{_config_file_name_}]}/exportview?option=cdna;action=select;format=fasta;type1=transcript;anchor1=$tid",
  };

  if ($transcript->external_name()){
    $id = $transcript->external_name();
    $zmenu->{"00:$id"}= '';
  }   

  if($pid) {
    $zmenu->{"03:Peptide:$pid"}   = qq(/@{[$self->{container}{_config_file_name_}]}/protview?peptide=$pid);
    $zmenu->{'05:Export Peptide'} = qq(/@{[$self->{container}{_config_file_name_}]}/exportview?option=peptide;action=select;format=fasta;type1=peptide;anchor1=$pid);	
  }
  return $zmenu;
}

sub gene_zmenu {
  my ($self, $gene ) = @_;
  my $gid = $gene->stable_id();
  my $zmenu = {
    'caption'                   => "TIGR Gene",
    "01:Gene:$gid"          => "/@{[$self->{container}{_config_file_name_}]}/geneview?gene=$gid",
  };
  $zmenu->{"00:@{[$gene->external_name()]}"} = '' if $gene->external_name();
  return $zmenu;
}

sub text_label {
  my ($self, $gene, $transcript) = @_;
  my $tid = $transcript->stable_id();
  my $id  = ($transcript->external_name() eq '') ? $tid : $transcript->external_name();

  if( $self->{'config'}->{'_both_names_'} eq 'yes') {
    return $tid.(($transcript->external_name() eq '') ? '' : " ($id)" );
  }

  return $self->{'config'}->{'_transcript_names_'} eq 'yes' ? $id : "";    
}

sub gene_text_label {
  my ($self, $gene ) = @_;
  my $gid = $gene->stable_id();
  my $id  = ($gene->external_name() eq '') ? $gid : $gene->external_name();
  if( $self->{'config'}->{'_both_names_'} eq 'yes') {
    return $gid.(($gene->external_name() eq '') ? '' : " ($id)" );
  }
  return $self->{'config'}->{'_transcript_names_'} eq 'yes' ? $id : "";
}


sub features {
  my ($self) = @_;
  my $track = 'tigr_0_5_transcript';
  my $slice = $self->{'container'};
  my @genes;
  foreach my $analysis( 'tigr_0_5' ){
    push @genes, @{ $slice->get_all_Genes( $analysis ) }
  }
  return [@genes];
}

sub legend {
  my ($self, $colours) = @_;
  return ('tigr_0_5', 1000, 
    [ 'TIGR genes' => $colours->{'tigr_0_5'}[0], ]
  );
}

sub error_track_name { return 'TIGR proteins'; }

1;
