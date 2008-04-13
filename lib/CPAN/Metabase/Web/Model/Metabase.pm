use strict;
use warnings;
package CPAN::Metabase::Web::Model::Metabase;
use base 'Catalyst::Model';

use CPAN::Metabase::Gateway;
use CPAN::Metabase::Fact::TestFact;
use CPAN::Metabase::Librarian;
use CPAN::Metabase::Archive::Filesystem;
use CPAN::Metabase::Index::FlatFile;

my $gateway;
sub gateway {
  my ($self) = @_;

  $gateway ||= CPAN::Metabase::Gateway->new({
    fact_classes => [ 'CPAN::Metabase::Fact::TestFact' ],
    librarian    => CPAN::Metabase::Librarian->new({
      archive => CPAN::Metabase::Archive::Filesystem->new({
        root_dir => $self->{archive_root},
      }),
      index   => CPAN::Metabase::Index::FlatFile->new({
        index_file => 'index.txt',
      }),
    })
  });
}

sub librarian { $_[0]->gateway->librarian }

1;
