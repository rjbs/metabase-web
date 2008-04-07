# Copyright (c) 2008 by Ricardo SIGNES. All rights reserved.
# Licensed under terms of Perl itself (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://dev.perl.org/licenses/

require 5.004;
use ExtUtils::MakeMaker;
my $dist = 'CPAN-Metabase-Web';
(my $meta_from = $dist ) =~ s{-}{/}g;
$meta_from = "lib/$meta_from\.pm";
WriteMakefile(
    DIST_NAME     => $dist,
    AUTHOR        => 'Ricardo SIGNES <rjbs@cpan.org>',
    ABSTRACT_FROM => $meta_from,
    VERSION_FROM  => $meta_from,
    PREREQ_PM     => {
        'Test::Simple' => 0.47, 
    },
);
