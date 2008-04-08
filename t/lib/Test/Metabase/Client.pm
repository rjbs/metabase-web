use strict;
use warnings;
package Test::Metabase::Client;
use base 'CPAN::Metabase::Client';

use Catalyst::Test 'CPAN::Metabase::Web';

our $VERSION = '0.001';

sub http_request {
  my ($self, $req) = @_;
  request($req);
}

sub abs_url { "/$_[1]"; }

1;
