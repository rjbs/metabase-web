#!/usr/bin/perl
use strict;
use warnings;
use lib 't/lib';

use Test::More 'no_plan';
use Test::Metabase::Web::Config;
use Test::Metabase::Client;

use CPAN::Metabase::User::Profile;

my $profile = CPAN::Metabase::User::Profile->open({
  resource => 'metabase:user:74B9A2EA-1D1A-11DE-BE21-DD62421C7A0A',
  guid     => '74B9A2EA-1D1A-11DE-BE21-DD62421C7A0A',
});

$profile->add( 'CPAN::Metabase::User::EmailAddress' => 'jdoe@example.com' );
$profile->add( 'CPAN::Metabase::User::FullName'     => 'John Doe' );
$profile->add( 'CPAN::Metabase::User::Secret'       => 'aixuZuo8' );

$profile->close;

my $client = Test::Metabase::Client->new({ profile => $profile });

my $fact = CPAN::Metabase::Fact::TestFact->new({
  resource => 'RJBS/Foo-Bar-1.23.tar.gz',
  content  => 'this power powered by power',
});

my $ok = eval { $client->submit_fact($fact); 1 };
ok($ok, "resource created!") or diag $@;

my $fact_struct = $client->retrieve_fact_raw($fact->guid);

my $retr_fact  = CPAN::Metabase::Fact::TestFact->from_struct($fact_struct);

is($retr_fact->guid, $fact->guid, "we got the same guid-ed fact");
is_deeply(
  $retr_fact->content,
  $fact->content,
  "content is identical, too",
);

is($retr_fact->creator_id, $profile->guid, 'fact has correct creator');
