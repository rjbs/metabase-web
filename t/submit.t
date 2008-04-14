#!/usr/bin/perl
use strict;
use warnings;
use lib 't/lib';

use Test::More 'no_plan';
use Test::Metabase::Web::Config;
use Test::Metabase::Client;
use CPAN::Metabase::Fact::TestFact;

my $client = Test::Metabase::Client->new({
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
