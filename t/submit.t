#!/usr/bin/perl
use strict;
use warnings;
use lib 't/lib';

use Test::More 'no_plan';
use Test::Metabase::Web::Config;
use Test::Metabase::Client;

use CPAN::Metabase::User::Profile;

{
  # We use this guy for submitting.
  my $ok_profile = CPAN::Metabase::User::Profile->open({
    resource => 'metabase:user:74B9A2EA-1D1A-11DE-BE21-DD62421C7A0A',
    guid     => '74B9A2EA-1D1A-11DE-BE21-DD62421C7A0A',
  });

  $ok_profile->add('CPAN::Metabase::User::EmailAddress' => 'jdoe@example.com');
  $ok_profile->add('CPAN::Metabase::User::FullName'     => 'John Doe');
  $ok_profile->add('CPAN::Metabase::User::Secret'       => 'aixuZuo8');

  $ok_profile->close;

  my $ok_client = Test::Metabase::Client->new({ profile => $ok_profile });

  Test::Metabase::Web::Config->gateway->secret_librarian->store($ok_profile);

  my $fact = CPAN::Metabase::Fact::TestFact->new({
    resource => 'RJBS/Foo-Bar-1.23.tar.gz',
    content  => 'this power powered by power',
  });

  my $ok = eval { $ok_client->submit_fact($fact); 1 };
  ok($ok, "resource created!") or diag $@;

  my $fact_struct = $ok_client->retrieve_fact_raw($fact->guid);

  my $retr_fact  = CPAN::Metabase::Fact::TestFact->from_struct($fact_struct);

  is($retr_fact->guid, $fact->guid, "we got the same guid-ed fact");
  is_deeply(
    $retr_fact->content,
    $fact->content,
    "content is identical, too",
  );

  is($retr_fact->creator_id, $ok_profile->guid, 'fact has correct creator');
}

{
  # We use this guy for failing to submit.  He is not stored in the s_l.
  my $bad_profile = CPAN::Metabase::User::Profile->open({
    resource => 'metabase:user:499DE666-1D7E-11DE-84B6-1B03411C7A0A',
    guid     => '499DE666-1D7E-11DE-84B6-1B03411C7A0A',
  });

  $bad_profile->add('CPAN::Metabase::User::EmailAddress' => 'gorp@example.com');
  $bad_profile->add('CPAN::Metabase::User::FullName'     => 'Gorp Zug');
  $bad_profile->add('CPAN::Metabase::User::Secret'       => 'stroguuu');

  $bad_profile->close;

  my $bad_client = Test::Metabase::Client->new({ profile => $bad_profile });

  my $fact = CPAN::Metabase::Fact::TestFact->new({
    resource => 'RJBS/Foo-Bar-1.23.tar.gz',
    content  => 'this power powered by power',
  });

  my $ok    = eval { $bad_client->submit_fact($fact); 1 };
  my $error = $@;
  ok(! $ok, "resource rejected!");
  like($error, qr/unknown submitter/, "rejected for the right reasons");
}

{
  # We use this guy for failing to submit.  He is in MB, but secret is wrong.
  my $bad_pw = CPAN::Metabase::User::Profile->open({
    resource => 'metabase:user:74B9A2EA-1D1A-11DE-BE21-DD62421C7A0A',
    guid     => '74B9A2EA-1D1A-11DE-BE21-DD62421C7A0A',
  });

  $bad_pw->add('CPAN::Metabase::User::EmailAddress' => 'jdoe@example.com');
  $bad_pw->add('CPAN::Metabase::User::FullName'     => 'John Doe');
  $bad_pw->add('CPAN::Metabase::User::Secret'       => 'toriamos');

  $bad_pw->close;

  my $bad_client = Test::Metabase::Client->new({ profile => $bad_pw });

  my $fact = CPAN::Metabase::Fact::TestFact->new({
    resource => 'RJBS/Foo-Bar-1.23.tar.gz',
    content  => 'this power powered by power',
  });

  my $ok    = eval { $bad_client->submit_fact($fact); 1 };
  my $error = $@;
  ok(! $ok, "resource rejected!");
  like($error, qr/unknown submitter/, "rejected for the right reasons");
}
