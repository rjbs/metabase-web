#!/usr/bin/env perl
use strict;
use warnings;
use Path::Class;
use File::Temp;

my $dir = shift @ARGV;
$dir ||= File::Temp::tempdir( CLEANUP => 1 );
die "'$dir' is not a directory\n" unless -d $dir;

system( 'generate_config.pl', $dir );
system( 'cpan-testers-metabase.pl', '-C', file($dir,'test.json') );

