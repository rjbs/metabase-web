#!/usr/bin/perl
use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Test::Metabase::Web::Config ( allow_registration => 1 );
use Test::Metabase::Client;

use Metabase::User::Profile;
use Metabase::User::Secret;

my $ok_profile;
my $ok_secret;
my $ok_password = 'aixuZuo8';

{
  # We use this guy for submitting.
  $ok_profile = Metabase::User::Profile->create({
    email_address => 'jdoe@example.com',
    full_name     => 'John Doe',
  }) or die "Couldn't create test profile";

  $ok_profile->close;

  $ok_secret = Metabase::User::Secret->new(
    resource => $ok_profile->resource,
    content => $ok_password,
  ) or die "Couldn't create test secret";

  my $ok_client = Test::Metabase::Client->new({ profile => $ok_profile, secret => $ok_secret });

  my $fact = Test::Metabase::StringFact->new({
    resource => 'cpan:///distfile/RJBS/Foo-Bar-1.23.tar.gz',
    content  => 'this power powered by power',
  });

  my $ok = eval { $ok_client->submit_fact($fact); 1 };
  ok($ok, "resource created!") or diag $@;

  # Should have autoregistered during submission

  ok( Test::Metabase::Web::Config->gateway->public_librarian->extract($ok_profile->guid), "retrieve registered profile" );
  ok( Test::Metabase::Web::Config->gateway->private_librarian->extract($ok_secret->guid), "retrieve registered secret" );

  my $fact_struct = $ok_client->retrieve_fact_raw($fact->guid);
  ok( $fact_struct, "got a fact struct back" );

  my $retr_fact  = Test::Metabase::StringFact->from_struct($fact_struct);
  is($retr_fact->creator, $ok_profile->resource, 'fact has correct creator');
}

done_testing;

