use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'IO::Socket::Happpy::EyeBalls',
    license             => 'perl',
    dist_author         => 'Masanori Hara <massa.hara at gmail.com>',
    dist_version_from   => 'lib/IO/Socket/Happpy/EyeBalls.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'IO-Socket-Happpy-EyeBalls-*' ],
);

$builder->create_build_script();
