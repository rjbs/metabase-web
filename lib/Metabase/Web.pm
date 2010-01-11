package Metabase::Web;

use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;
use Catalyst qw/ConfigLoader/;

our $VERSION = '0.001';
$VERSION = eval $VERSION; # convert '1.23_45' to 1.2345

__PACKAGE__->config(
    name => __PACKAGE__,
    disable_component_resolution_regex_fallback => 1,
);

__PACKAGE__->setup;

1;
