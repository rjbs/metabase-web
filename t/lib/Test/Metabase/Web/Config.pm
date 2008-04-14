use strict;
use warnings;
package Test::Metabase::Web::Config;

use File::Temp ();
use Path::Class;
use YAML::Syck;

sub import {
  my $root        = dir(File::Temp::tempdir(CLEANUP => 1));
  (my $archive_dir = $root->subdir('store'))->mkpath;
  my $index_file  = $root->file('index.txt');
  close $index_file->openw; # create the file, least the exists-check die!

  my $config = {
    archive => { root_dir   => $archive_dir },
    index   => { index_file => $index_file  },
    fact_classes => [ 'CPAN::Metabase::Fact::TestFact' ],
  };

  my $config_file = dir($root)->file('test.yaml');
  YAML::Syck::DumpFile("$config_file", { 'Model::Metabase' => $config });
  $ENV{CPAN_METABASE_WEB_CONFIG} = $config_file;
}

1;
