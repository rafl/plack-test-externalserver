use strict;
use warnings;

package Plack::Test::ExternalServer;

use URI;
use Carp;
use LWP::UserAgent;

sub test_psgi {
    my %args = @_;

    my $client = delete $args{client} or croak 'client test code needed';
    my $ua     = delete $args{ua} || LWP::UserAgent->new;
    my $base   = $ENV{PLACK_TEST_EXTERNALSERVER_URI} || delete $args{uri};
       $base   = URI->new($base) if $base;

    $client->(sub {
        my ($req) = shift->clone;

        if ($base) {
            my $uri = $req->uri->clone;
            $uri->scheme($base->scheme);
            $uri->host($base->host);
            $uri->port($base->port);
            $uri->path($base->path . $uri->path);
            $req->uri($uri);
        }

        return $ua->request($req);
    });
}

1;
