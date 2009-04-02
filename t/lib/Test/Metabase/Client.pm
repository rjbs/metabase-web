use strict;
use warnings;
package Test::Metabase::Client;
use base 'Metabase::Client::Simple';

use Catalyst::Test 'Metabase::Web';

our $VERSION = '0.001';

sub new {
  my ($self, $arg) = @_;
  $self->SUPER::new({
    url => 'http://metabase.cpan.example/',
    %$arg,
  });
}

sub http_request {
  my ($self, $req) = @_;
  request($req);
}

sub abs_url { "/$_[1]"; }

1;
