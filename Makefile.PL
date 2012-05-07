use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'IO::Socket::Happpy::EyeBalls',
    AUTHOR              => 'Masanori Hara <massa.hara at gmail.com>',
    VERSION_FROM        => 'lib/IO/Socket/Happpy/EyeBalls.pm',
    ABSTRACT_FROM       => 'lib/IO/Socket/Happpy/EyeBalls.pm',
    PL_FILES            => {},
    LICENSE             => 'perl',
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'IO-Socket-Happpy-EyeBalls-*' },
);
