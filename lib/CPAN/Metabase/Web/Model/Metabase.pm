use strict;
use warnings;
package CPAN::Metabase::Web::Model::Metabase;
use base 'Catalyst::Model';

use lib "$ENV{HOME}/code/projects/CPAN-Metabase/lib";
use CPAN::Metabase::Gateway;
use CPAN::Metabase::Archive::Filesystem;

my $archive = CPAN::Metabase::Archive::Filesystem->new({
  root_dir => './mb',
});

my $gateway = CPAN::Metabase::Gateway->new({
  fact_classes => [ 'CPAN::Metabase::Fact::TestFact' ],
  archive      => $archive,
});

sub gateway { $gateway }
sub archive { $archive }

1;
