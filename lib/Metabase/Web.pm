package Metabase::Web;
use strict;
use warnings;

our $VERSION = '0.001';
$VERSION = eval $VERSION;

use Catalyst::Runtime '5.70';
use Catalyst qw/ConfigLoader/;

__PACKAGE__->config(name => __PACKAGE__);
__PACKAGE__->setup;

1;
