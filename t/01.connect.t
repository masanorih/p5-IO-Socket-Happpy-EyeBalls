use lib '../lib';
use Test::More;
use Socket qw(:all);

if ( $ENV{TEST_IPV6HOST} ) {
    use_ok('IO::Socket::Happpy::EyeBalls');

    my $socket = IO::Socket::Happpy::EyeBalls->new(
        Proto    => 'tcp',
        PeerAddr => $ENV{TEST_IPV6HOST},
        PeerPort => 80,
        Type     => SOCK_STREAM,
        Timeout  => 10,
    );

    ok $socket, 'ok new';
    ok $socket->connected, "socket is connected to $ENV{TEST_IPV6HOST}";
    my $familyname =
        ( $socket->sockdomain == PF_INET6 ) ? "IPv6"
        : ( $socket->sockdomain == PF_INET )  ? "IPv4"
        :                                       undef;
    ok $familyname, "domain family is $familyname";

    is $socket->blocking, 1, 'socket is blocking mode by default';
    $socket->close;
    # specify non-blocking
    $socket = IO::Socket::Happpy::EyeBalls->new(
        Proto    => 'tcp',
        PeerAddr => $ENV{TEST_IPV6HOST},
        PeerPort => 80,
        Type     => SOCK_STREAM,
        Blocking => 0,
        Timeout  => 10,
    );
    is $socket->blocking, 0, 'socket is non-blocking mode now';
    $socket->close;
    # specify blocking
    $socket = IO::Socket::Happpy::EyeBalls->new(
        Proto    => 'tcp',
        PeerAddr => $ENV{TEST_IPV6HOST},
        PeerPort => 80,
        Type     => SOCK_STREAM,
        Blocking => 1,
        Timeout  => 10,
    );
    ok $socket->connected, "socket is connected to $ENV{TEST_IPV6HOST}";
    is $socket->blocking, 1, 'socket is blocking mode now';

    done_testing;
}
else {
    plan skip_all => 'set TEST_IPV6HOST for testing connect test';
}
