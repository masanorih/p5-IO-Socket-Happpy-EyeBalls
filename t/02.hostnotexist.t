use lib '../lib';
use Test::More;

use_ok('IO::Socket::Happpy::EyeBalls');
my $socket = IO::Socket::Happpy::EyeBalls->new(
    Proto    => 'tcp',
    PeerAddr => 'ipv6.example.com',
    PeerPort => 80,
);

is $socket, undef, '$socket is undef';
done_testing;
