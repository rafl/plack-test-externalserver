use strict;
use warnings;
use Test::More;

BEGIN { $ENV{PLACK_TEST_IMPL} = 'ExternalServer' }
use Plack::Test;

use Test::TCP;
use Plack::Loader;
use HTTP::Request::Common;

my $app = sub {
    my ($env) = @_;
    return [ 200, ['Content-Type' => 'text/plain'], ['moo'] ];
};

test_tcp(
    client => sub {
        my ($port) = @_;

        local $ENV{PLACK_TEST_EXTERNALSERVER_URI} = "http://127.0.0.1:${port}";

        test_psgi
            client => sub {
                my ($cb) = @_;
                my $res = $cb->(GET '/');
                ok($res->is_success);
                is($res->content, 'moo');
            };
    },
    server => sub {
        my ($port) = @_;
        my $server = Plack::Loader->auto(port => $port, host => '127.0.0.1');
        $server->run($app);
    },
);

done_testing;
