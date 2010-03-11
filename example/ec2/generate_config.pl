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
  Param("logprefix|l")->required,
]);

my $config = {
  'Model::Metabase' => {
    class => 'CPAN::Testers::Metabase::AWS',
    args => {
      bucket => $opts->get_bucket,
      namespace => $opts->get_namespace,
    },        
  },
  'Log::Dispatch' => [
    {
      class => 'Syslog',
      min_level => 'info',
      ident => $opts->get_logprefix,
    }
  ],
};

my $config_file = file($opts->get_config);
warn "\nWARNING: $config_file file does not have a .json suffix\n\n"
    unless $config_file =~ /\.json$/;

my $fh = $config_file->openw;
print { $fh } JSON->new->encode($config);
close $fh;
print "Wrote '$config_file'\n";

