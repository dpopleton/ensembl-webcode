package EnsEMBL::Web::Document::Configure;

use CGI qw(escapeHTML);
use strict;
use warnings;

use EnsEMBL::Web::Root;
use EnsEMBL::Web::Object::User;

our @ISA  = qw(EnsEMBL::Web::Root);

sub common_menu_items {
  my( $self, $doc ) = @_;
## Now the links on the left hand side....

  if ($doc->species_defs->ENSEMBL_LOGINS) {
    ## Is the user logged in?
    my $user_id = $ENV{'ENSEMBL_USER_ID'};

    my $user_adaptor = EnsEMBL::Web::DBSQL::UserDB->new();

    my $flag = 'ac_mini';
    $doc->menu->add_block( $flag, 'bulleted', "Your Ensembl", 'priority' => 0 );

    if ($user_id) {
      $doc->menu->add_entry( $flag, 'text' => "Logged in &middot; <a href='javascript:logout_link()'>Log out</a>", 'raw' => 'yes');
      #$doc->menu->add_entry( $flag, 'text' => "Bookmark this page",
      #                              'code' => 'bookmark',
      #                            'href' => "javascript:bookmark_link()" );

      my $user = EnsEMBL::Web::Object::User->new({'adaptor'=>$user_adaptor, 'id'=>$user_id});

      ## Link to existing bookmarks
      my @records = $user->bookmark_records({order_by => 'click' });
      if ($#records > 0) { 
        my @bookmark_sections = ();
        my $max_bookmarks = 5;
        if ($#records < $max_bookmarks) {
          $max_bookmarks = $#records;
        }
        for my $n (0..$max_bookmarks) {
          my $url = $records[$n]->url;
          $url =~ s/\?/\\\?/g;
          $url =~ s/&/!and!/g;
          $url =~ s/;/!with!/g;
          push @bookmark_sections, { href => "/common/redirect?url=" . $url . "&id=" . $records[$n]->id, 
                                   text => $records[$n]->name, extra_icon => '/img/bullet_star.png' }; 
        }

        push @bookmark_sections, { 'href' => 'javascript:bookmark_link()', 
                                 'text'  => 'Bookmark this page', extra_icon => '/img/bullet_toggle_plus.png' };

        push @bookmark_sections, { 'href' => '/account', 
                                 'text'  => 'More bookmarks...', extra_icon => '/img/bullet_go.png' };

        $doc->menu->add_entry(
          $flag,
          'href'=>'/account',
          'text'=>'Bookmarks',
          'options'=>\@bookmark_sections,       );
      }
      $doc->menu->add_entry( $flag, 'text' => "Your account",
                                  'href' => "/account/" );
    }
    else {
      $doc->menu->add_entry( $flag, 'text' => "<a href='javascript:login_link();'>Login</a> or <a href='/common/register'>Register</a>", 'raw' => 'yes');
      $doc->menu->add_entry( $flag, 'text' => "About User Accounts",
                                  'href' => "/info/about/accounts.html",
                                  'icon' => '/img/infoicon.gif' );
    }
  }

}

sub static_menu_items {
  my( $self, $doc ) = @_;

  $doc->menu->add_block( 'docs', 'bulleted', 'Help & Documentation', 'priority' => 20 );

  $doc->menu->add_entry('docs', 'href'=>'/info/',         'text'=>'Table of Contents');
  $doc->menu->add_entry('docs', 'href'=>'/info/helpdesk', 'text'=>'Helpdesk');
  $doc->menu->add_entry('docs', 'href'=>'/info/about/',   'text'=>'About Ensembl');
  $doc->menu->add_entry('docs', 'href'=>'/info/data/download.html', 'text'=>'Downloading data');
  $doc->menu->add_entry('docs', 'href'=>'/info/data/index.html#import', 'text'=>'Displaying your own data');
  $doc->menu->add_entry('docs', 'href'=>'/info/software/','text'=>'Ensembl software');


}

sub dynamic_menu_items {
  my( $self, $doc ) = @_;

  ## Is the user logged in?
  my $user_id = $ENV{'ENSEMBL_USER_ID'};

  if ($user_id) {
    my $flag = 'ac_mini';
      ## to do - add a check for configurability
      my $configurable = 1;
      if ($configurable) {
        $doc->menu->add_entry_after( $flag, 'bookmark', 
                                    'text' => "Save this configuration",
                                  'href' => "javascript:config_link()" );
      }
  }
}

1;
