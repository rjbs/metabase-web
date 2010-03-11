#!/usr/bin/env perl
use strict;
use warnings;
use Path::Class;
use JSON;
use Config::Tiny;

my ($filename) = @ARGV;
die "Usage: $0 <filename>\n" unless $filename;

my $config = {
  'Model::Metabase' => {
    class => 'CPAN::Testers::Metabase::AWS',
  }
};

my $config_file = file($filename);
my $fh = $config_file->openw;
print { $fh } JSON->new->encode($config);
close $fh;
print "Wrote '$config_file'\n";

