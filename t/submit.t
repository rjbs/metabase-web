#!/usr/bin/perl
use strict;
use warnings;

use lib 't/lib';

use Test::More 'no_plan';

use File::Temp ();
use Path::Class;
use YAML::Syck;

BEGIN {
  my $root        = File::Temp::tempdir(CLEANUP => 1);
  (my $archive_dir = dir($root)->subdir('store'))->mkpath;

  my $config = {
    'Model::Metabase' => {
      archive_root => "$archive_dir",
    }
  };

  my $config_file = dir($root)->file('test.yaml');
  YAML::Syck::DumpFile("$config_file", $config);
  $ENV{CPAN_METABASE_WEB_CONFIG} = $config_file;
}

use Test::Metabase::Client;
use CPAN::Metabase::Fact::TestFact;

my $client = Test::Metabase::Client->new({
  url  => 'http://localhost:3000',
  user => 'rjbs',
  key  => 'kidneys',
});

my $fact = CPAN::Metabase::Fact::TestFact->new({
  dist_author => 'RJBS',
  dist_file   => 'Foo-Bar-1.23.tar.gz',
  content     => 'this power powered by power',
});

my $res = $client->submit_fact($fact);

is($res->code, 201, "resource created!");