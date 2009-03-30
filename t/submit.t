#!/usr/bin/perl
use strict;
use warnings;
use lib 't/lib';

use Test::More 'no_plan';
use Test::Metabase::Web::Config;
use Test::Metabase::Client;

my $client = Test::Metabase::Client->new({
  # XXX: Clearly this should be a fact. -- rjbs, 2009-03-30
  profile => { metadata => { core => { guid => 'rjbs' } } }
});

my $fact = CPAN::Metabase::Fact::TestFact->new({
  resource => 'RJBS/Foo-Bar-1.23.tar.gz',
  content  => 'this power powered by power',
});

my $res = $client->submit_fact($fact);
is($res->code, 201, "resource created!");
