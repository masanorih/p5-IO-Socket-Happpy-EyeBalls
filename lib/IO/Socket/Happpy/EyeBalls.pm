package IO::Socket::Happpy::EyeBalls;

use warnings;
use strict;
use Carp;
use Socket qw(:all);
use Time::HiRes qw(usleep);
use parent qw(IO::Socket::INET);

use version; our $VERSION = qv('0.0.1');
our $IPV6_CACHE;

sub configure {
    my( $self, $args ) = @_;

    if ( $self->_has_ipv6_cache ) {
        my $peer    = $IPV6_CACHE->[1];
        my $timeout = $args->{ConnectTimeout} || 300000;
        my $result  = $self->_nonblock_connect( $peer, $timeout );
        if ( defined $result ) {
            $self->_restore_blocking($args);
            return $self;
        }
    }
    else {
        my $hints;
        $hints->{socktype} = $args->{Type} if exists $args->{Type};
        $hints->{family} = AF_INET6;
        # default is 300ms
        my $timeout = $args->{ConnectTimeout} || 300000;
        my $host    = $args->{PeerAddr};
        my $service = $args->{PeerPort};
        my( $err, @peerinfo ) = getaddrinfo $host, $service, $hints;
        if ( not $err ) {
            for my $peer (@peerinfo) {
                my $result = $self->_nonblock_connect( $peer, $timeout );
                if ( defined $result ) {
                    $self->_restore_blocking($args);
                    $IPV6_CACHE = [ time(), $peer ];
                    return $self;
                }
            }
        }
    }
    # fallback to parent class
    $self->SUPER::configure($args);
}

sub _has_ipv6_cache {
    my $self = shift;
    return unless $IPV6_CACHE;
    my $time = $IPV6_CACHE->[0];
    my $peer = $IPV6_CACHE->[1];
    # flash old cache
    if ( time > $time + 600 ) {
        $IPV6_CACHE = undef;
        return;
    }
    return 1;
}

sub _restore_blocking {
    my( $self, $args ) = @_;
    my $blocking = exists $args->{Blocking} ? $args->{Blocking} : 1;
    $self->blocking($blocking) if $blocking;
}

sub _nonblock_connect {
    my( $self, $peer, $timeout ) = @_;
    my $proto    = $peer->{protocol};
    my $family   = $peer->{family};
    my $socktype = $peer->{socktype};
    my $addr     = $peer->{addr};

    my $result;
    $result = $self->socket( $family, $socktype, $proto );
    $self->blocking(0);
    $result or croak "failed to open socket";
    $result = CORE::connect( $self, $addr );
    my $period = $timeout / 10;
    for ( 1 .. 10 ) {    # trivial event watcher...
        return 1 if $self->connected;
        usleep $period;
    }
    $self->blocking(1);
    $self->close;
    return;
}

1;
__END__

=head1 NAME

IO::Socket::Happpy::EyeBalls - Perl implementation of RFC6555 - Happy Eyeballs


=head1 VERSION

This document describes IO::Socket::Happpy::EyeBalls version 0.0.1


=head1 SYNOPSIS

    use IO::Socket::Happpy::EyeBalls;
    my $socket = IO::Socket::Happpy::EyeBalls->new(
        Proto    => 'tcp',
        PeerAddr => $addr,
        PeerPort => $port,
    );
    $socket->connected;
    warn $socket->sockdomain # PF_INET or PF_INET6

=head1 DESCRIPTION

This module is Perl implementation of RFC6555 - Happy Eyeballs.

The implementation of RFC6555 here is same as web browsers implementation 
such as google chrome or firefox,
describes as "6.  Example Algorithm" in RFC6555 as far as I understand.

This modules tries to connect ipv6 address first if exists.
Wait for 300ms (can be changed by ConnectTimeout param).
if the session has be connected before its timeout, returns ipv6 socket.
Otherwise passes arguments to base class (IO::Socket::INET).
# And it tries to connect ipv4 address.

This module is yet experimental. There are plenty way to implement RFC6555 and this is one example.

Known issues below.

- Namespace is too long. Maybe it does not require the indipendent namespace but an option paramater of the IO::Socket::IP is enough. Like this.

    my $socket = IO::Socket::IP->new(
        Proto     => 'tcp',
        PeerAddr  => $addr,
        PeerPort  => $port,
        Algorithm => 'happyeyeballs',
    );

- AE::io is better for the io watcher to detect if the ipv6 socket has been connected. I don't use it because for the simplicity though.


=head2 Methods

=over

=item configure

override the configure method and tries to connect ipv6 first.
Fall backs to base class method is ipv6 connection fails.

=back


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to AUTHOR.


=head1 AUTHOR

Masanori Hara  C<< <massa.hara at gmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Masanori Hara C<< <massa.hara at gmail.com> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
