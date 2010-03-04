#!/usr/bin/perl
use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Test::Metabase::Web::Config (allow_registration => 0);
use Test::Metabase::Client;
use Test::Metabase::StringFact;

use Metabase::User::Profile;
use Metabase::User::Secret;

diag "Test metabase located at " . Test::Metabase::Web::Config->storage_dir;

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

  ok( Test::Metabase::Web::Config->gateway->public_librarian->store($ok_profile), "register profile" );
  ok( Test::Metabase::Web::Config->gateway->public_librarian->extract($ok_profile->guid), "test retrieve profile" );
  ok( Test::Metabase::Web::Config->gateway->private_librarian->store($ok_secret), "register secret" );
  ok( Test::Metabase::Web::Config->gateway->private_librarian->extract($ok_secret->guid), "test retrieve secret" );
  my $found = Test::Metabase::Web::Config->gateway->private_librarian->search(
    'core.type' => 'Metabase-User-Secret',
    'core.resource' => $ok_profile->resource->resource,
  );
  ok( scalar @$found, "search finds secret" );

  my $fact = Test::Metabase::StringFact->new({
    resource => 'cpan:///distfile/RJBS/Foo-Bar-1.23.tar.gz',
    content  => 'this power powered by power',
  });

  my $ok = eval { $ok_client->submit_fact($fact); 1 };
  ok($ok, "resource created!") or diag $@;

  my $fact_struct = $ok_client->retrieve_fact_raw($fact->guid);

  ok( $fact_struct, "got a fact struct back" );

  my $retr_fact  = Test::Metabase::StringFact->from_struct($fact_struct);

  is($retr_fact->guid, $fact->guid, "we got the same fact guid back");
  is_deeply(
    $retr_fact->content,
    $fact->content,
    "content is identical, too",
  );

  is($retr_fact->creator, $ok_profile->resource, 'fact has correct creator');
}

{
  # We use this guy for failing to submit.  He is not stored in the s_l
  # and new registrations are disabled in the test Metabase Gateway
  my $bad_profile = Metabase::User::Profile->create({
    # resource => 'metabase:user:499DE666-1D7E-11DE-84B6-1B03411C7A0A',
    # guid     => '499DE666-1D7E-11DE-84B6-1B03411C7A0A',
    email_address => 'gorp@example.com',
    full_name     => 'Gorp Zug',
  });

  my $bad_secret = Metabase::User::Secret->new(
    resource => $bad_profile->resource,
    content => 'dafdadfa'
  );

  $bad_profile->close;

  my $bad_client = Test::Metabase::Client->new({ profile => $bad_profile, secret => $bad_secret });

  my $fact = Test::Metabase::StringFact->new({
    resource => 'cpan:///distfile/RJBS/Foo-Bar-1.23.tar.gz',
    content  => 'this power powered by power',
  });

  my $ok     = eval { $bad_client->submit_fact($fact); 1 };
  my $error = $@;
  ok(! $ok, "resource rejected!");
  like($error, qr/registration disabled/m, "rejected for the right reasons");
}

{
  # We use this guy for failing to submit.  He is in MB, but secret is wrong.
  my $ok_struct = $ok_secret->as_struct;
  $ok_struct->{content} =~ s/\Q$ok_password/bad-secret/;
  my $bad_pw = Metabase::User::Secret->from_struct($ok_struct);

  my $bad_client = Test::Metabase::Client->new({ profile => $ok_profile, secret => $bad_pw });

  my $fact = Test::Metabase::StringFact->new({
    resource => 'cpan:///distfile/RJBS/Foo-Bar-1.23.tar.gz',
    content  => 'this power powered by power',
  });

  my $ok    = eval { $bad_client->submit_fact($fact); 1 };
  my $error = $@;
  ok(! $ok, "resource rejected!");
  like($error, qr/user authentication failed/, "rejected for the right reasons");
}

done_testing;

