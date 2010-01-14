use strict;
use warnings;

package Plack::Test::ExternalServer;

use URI;
use Carp;
use LWP::UserAgent;

sub test_psgi {
    my %args = @_;

    my $client = delete $args{client} or croak 'client test code needed';
    my $ua     = delete $args{ua}  || LWP::UserAgent->new;
    my $base   = delete $args{uri} || $ENV{PLACK_TEST_EXTERNALSERVER_URI};
       $base   = URI->new($base) if $base;

    $client->(sub {
        my ($req) = @_;

        if ($base) {
            $req->uri->scheme($base->scheme);
            $req->uri->host($base->host);
            $req->uri->port($base->port);
            $req->uri->path($base->path . $req->uri->path);
        }

        return $ua->request($req);
    });
}

1;
