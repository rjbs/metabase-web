#!/usr/bin/env perl
use strict;
use warnings;
use Path::Class;
use JSON;
use Config::Tiny;
use Getopt::Lucid qw/:all/;

my $opts = Getopt::Lucid->getopt([
  Param("config|C")->required,
  Param("bucket|b")->required,
  Param("namespace|n")->required,
]);


my $config = {
  'Model::Metabase' => {
    class => 'CPAN::Testers::Metabase::AWS',
    args => {
      bucket => $opts->get_bucket,
      namespace => $opts->get_namespace,
    },        
  }
};

my $config_file = file($opts->get_config);
my $fh = $config_file->openw;
print { $fh } JSON->new->encode($config);
close $fh;
print "Wrote '$config_file'\n";

