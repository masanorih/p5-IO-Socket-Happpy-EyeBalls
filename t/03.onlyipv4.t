use lib '../lib';
use Test::More;
use Socket qw(:all);

if ( $ENV{TEST_IPV4HOST} ) {
    use_ok('IO::Socket::Happpy::EyeBalls');
    my $socket = IO::Socket::Happpy::EyeBalls->new(
        Proto    => 'tcp',
        PeerAddr => $ENV{TEST_IPV4HOST},
        PeerPort => 80,
        Type     => SOCK_STREAM,
    );

    ok $socket, 'ok new';
    ok $socket->connected, "socket is connected to $ENV{TEST_IPV4HOST}";
    is $socket->sockdomain, PF_INET, "domain family is IPv4";

    done_testing;
}
else {
    plan skip_all => 'set TEST_IPV4HOST for testing onlyipv4 test';
}
