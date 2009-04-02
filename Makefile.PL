require 5.006;
use inc::Module::Install;
all_from('lib/CPAN/Metabase/Web.pm');

requires('Metabase' => 0);

requires('Catalyst::Runtime' => 0);
requires('Data::GUID'        => 0);
requires('JSON'              => 2);

test_requires('Metabase::Client::Simple');

tests_recursive;
extra_tests;

WriteAll;
