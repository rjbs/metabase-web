require 5.006;
use inc::Module::Install;
all_from('lib/CPAN/Metabase/Web.pm');

requires('CPAN::Metabase' => 0);

requires('Catalyst::Runtime' => 0);
requires('Data::GUID'   => 0);

test_requires('CPAN::Metabase::Client::Simple');

tests_recursive;
extra_tests;

WriteAll;
