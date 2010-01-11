require 5.006;
use inc::Module::Install;
all_from('lib/Metabase/Web.pm');

requires('Metabase' => 0);

requires('Catalyst::Runtime' => 5.80);
requires('Catalyst::Plugin::ConfigLoader' => 0);
requires('Catalyst::Controller::REST' => 0);
requires('Data::GUID'        => 0);
requires('JSON'              => 2);

test_requires('Metabase::Client::Simple');

tests_recursive;
extra_tests;

WriteAll;
