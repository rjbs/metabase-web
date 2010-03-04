#!/usr/bin/env perl
use strict;
use warnings;
use Path::Class;
use JSON;
use Config::Tiny;

my ($root_dir) = @ARGV;
die "Usage: $0 <data-directory>\n" unless $root_dir;
die "Directory '$root_dir' doesn't exist\n" unless -d $root_dir;
$root_dir = dir($root_dir)->absolute;

my $aws_config = Config::Tiny->read($root_dir->file("/.awsconfig"))
  or die "failed to load config";
my $id = $aws_config->{_}{default};

my $config = {
  'Model::Metabase' => {
    class => 'CPAN::Testers::Metabase::AWS',
  }
};

my $config_file = $root_dir->file('config.json');
my $fh = $config_file->openw;
print { $fh } JSON->new->encode($config);
close $fh;
print "Wrote '$config_file'\n";

