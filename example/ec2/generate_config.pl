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
    gateway   => {
      CLASS => 'Metabase::Gateway',
      autocreate_profile => 1,
      disable_security => 1,  
      librarian => {
	CLASS => 'Metabase::Librarian',
	archive => { 
	  CLASS => 'Metabase::Archive::S3',
	  aws_access_key_id => $aws_config->{$id}{access_key},
	  aws_secret_access_key => $aws_config->{$id}{secret_access_key},
	  bucket     => 'cpantesters',
	  prefix     => 'dev/metabase/',
	  compressed => 1,
	},
	index   => { 
	  CLASS => 'Metabase::Index::SimpleDB',
	  aws_access_key_id => $aws_config->{$id}{access_key},
	  aws_secret_access_key => $aws_config->{$id}{secret_access_key},
	  domain     => 'cpantesters.dev.metabase',
	},
      },
      secret_librarian => {
	CLASS   => 'Metabase::Librarian',
	archive => { 
	  CLASS => 'Metabase::Archive::S3',
	  aws_access_key_id => $aws_config->{$id}{access_key},
	  aws_secret_access_key => $aws_config->{$id}{secret_access_key},
	  bucket     => 'cpantesters',
	  prefix     => 'dev/secret/metabase/',
	  compressed => 1,
	},
	index   => { 
	  CLASS => 'Metabase::Index::SimpleDB',
	  aws_access_key_id => $aws_config->{$id}{access_key},
	  aws_secret_access_key => $aws_config->{$id}{secret_access_key},
	  domain     => 'cpantesters.dev.secret.metabase',
	},
      },
    },
    fact_classes => [
      'Metabase::User::Profile',
      'CPAN::Testers::Report',
    ],
  }
};

my $config_file = $root_dir->file('config.json');
my $fh = $config_file->openw;
print { $fh } JSON->new->encode($config);
close $fh;
print "Wrote '$config_file'\n";

