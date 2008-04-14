#!/usr/bin/perl
use strict;
use warnings;

use lib 't/lib';

use Test::More 'no_plan';

use File::Temp ();
use Path::Class;
use YAML::Syck;

BEGIN {
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
