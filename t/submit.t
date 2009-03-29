#!/usr/bin/perl
use strict;
use warnings;
use lib 't/lib';

use Test::More 'no_plan';
use Test::Metabase::Web::Config;
use Test::Metabase::Client;

my $client = Test::Metabase::Client->new({
  user => 'rjbs',
  key  => 'kidneys',
});

my $fact = CPAN::Metabase::Fact::TestFact->new({
  resource => 'RJBS/Foo-Bar-1.23.tar.gz',
  content  => 'this power powered by power',
});

# XXX: have the client add this stuff
$fact->{metadata}{core}{user_id}  = [ Str => 'rjbs' ];

my $res = $client->submit_fact($fact);
is($res->code, 201, "resource created!");
