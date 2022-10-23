use warnings;
use strict;
use Test::Mojo;
use Test::More;

my $t = Test::Mojo->new('LenderXDemo');

# do not like relying on actual config nor tests over internet. should instead
# mock auth/endpoints, use env vars in test env...

$t->get_ok('/api/v1/event/subscriptions')
  ->status_is(200);
# tests are not idempotent, so testing replies is problematic...
is(ref($t->tx->res->json), 'ARRAY', 'response container');

# hardcoded public url in tests.
my $add = { url => 'https://13os.net/lenderxdemo', events => ['Event.Appraisal.Order.Assigned'] };
$t->post_ok('/api/v1/event/subscriptions', json => { add => [$add] })
  ->status_is(200)
  ->json_is('/added/0/events/0', $add->{events}->[0])
  ->json_is('/added/0/url', $add->{url});

my $added_event = $t->tx->res->json->{added}->[0];
$t->post_ok('/api/v1/event/subscriptions', json => { remove => [ $added_event->{event_subscription_id} ] })
  ->status_is(200)
  ->json_is('/removed/0/event_subscription_id', $added_event->{event_subscription_id})
  ->json_has('/removed/0/is_deleted');

$t->post_ok('/api/v1/test_order')
  ->status_is(200)
  ->json_has('/order_id');

done_testing();
