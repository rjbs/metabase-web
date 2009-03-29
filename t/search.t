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

{
  my @results = $client->search(simple => [
    'core.type' => 'CPAN-Metabase-Fact-TestFact'
  ]);

  is(@results, 0, "nothing found in brand-spanking-new archive");
}

{
  my $fact = CPAN::Metabase::Fact::TestFact->new({
    resource    => 'RJBS/Foo-Bar-1.23.tar.gz',
    content     => 'this power powered by power',
    user_id     => 'rjbs',
  });

  my $res = $client->submit_fact($fact);
  is($res->code, 201, "resource created!");
}

{
  my $fact = CPAN::Metabase::Fact::TestFact->new({
    resource    => 'RJBS/Bar-Baz-0.01.tar.gz',
    content     => 'heavens to murgatroid!',
    user_id     => 'rjbs',
  });

  my $res = $client->submit_fact($fact);
  is($res->code, 201, "resource created!");

  my $guid = $res->header('Location');
  $guid =~ s{^/guid/}{};

  my $res_2 = $client->retrieve_fact($guid);
  my $json = $res_2->content;
  my $struct = JSON->new->decode($json);

  my $retr_fact  = CPAN::Metabase::Fact::TestFact->from_struct($struct);

  is($retr_fact->guid, $fact->guid, "we got the same guid-ed fact");
  is_deeply(
    $retr_fact->content,
    $fact->content,
    "content is identical, too",
  );
}

{
  my @results = $client->search(simple => [
    'core.type' => 'CPAN-Metabase-Fact-TestFact'
  ]);

  is(
    @results,
    2,
    "we get two results for core.type = CPAN-Metabase-Fact-TestFact",
  );
}
