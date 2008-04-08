use strict;
use warnings;
package CPAN::Metabase::Web::Model::Metabase;
use base 'Catalyst::Model';

use lib "$ENV{HOME}/code/projects/CPAN-Metabase/lib";
use CPAN::Metabase::Gateway;
use CPAN::Metabase::Archive::Filesystem;

my $archive;
sub archive {
  $archive ||= CPAN::Metabase::Archive::Filesystem->new({
    root_dir => './mb',
  });
}

my $gateway;
sub gateway {
  $gateway = CPAN::Metabase::Gateway->new({
    fact_classes => [ 'CPAN::Metabase::Fact::TestFact' ],
    archive      => $_[0]->archive,
  });
}

1;
