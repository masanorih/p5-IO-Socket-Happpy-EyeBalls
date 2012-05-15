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
    );

    ok $socket, 'ok new';
    ok $socket->connected, "socket is connected to $ENV{TEST_IPV6HOST}";
    my $familyname =
        ( $socket->sockdomain == PF_INET6 ) ? "IPv6"
        : ( $socket->sockdomain == PF_INET )  ? "IPv4"
        :                                       undef;
    ok $familyname, "domain family is $familyname";

    done_testing;
}
else {
    plan skip_all => 'set TEST_IPV6HOST for testing connect test';
}
