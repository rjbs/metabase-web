package CPAN::Metabase::Web;
use strict;
use warnings;

our $VERSION = '0.001';
$VERSION = eval $VERSION; # convert '1.23_45' to 1.2345

use Catalyst::Runtime '5.70';
use Catalyst qw/ConfigLoader -Debug/;

__PACKAGE__->setup;
__PACKAGE__->config(name => __PACKAGE__);

1;
