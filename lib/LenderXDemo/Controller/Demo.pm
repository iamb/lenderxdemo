package LenderXDemo::Controller::Demo;
use Mojo::Base 'Mojolicious::Controller';

sub postback {
  my $c = shift;
  $c->app->log->debug('subscription event: '.$c->tx->req->body);
  $c->render(text => 'OK');
}

sub list_events {
  my $c = shift;
  my $tx = $c->app->client->list_events;
  $c->render(openapi => $tx->result->json);
}

sub manage_events {
  my $c = shift;
  return unless $c->openapi->valid_input;
  my $j = $c->req->json;
  my $client = $c->app->client;
  my (@added, @removed);
  for my $add (@{$j->{add} || []}) {
    my $tx = $client->add_async_event({}, json => {events => $add->{events}, url => $add->{url}});
    return $c->render(openapi => $tx->res->json, status => $tx->res->code) if $tx->result->is_error;
    push(@added, $tx->res->json);
  }
  for my $remove (@{$j->{remove} || []}) {
    # no operationId provided for removing subscriptions.
    my $url = $client->base_url->clone;
    $url->path->trailing_slash(1);
    $url->path("event/subscription/$remove");
    my $token = $client->token;
    my $tx = $client->ua->delete($url, {Authorization => "$token->{token_type} $token->{access_token}"});
    return $c->render(openapi => $tx->res->json, status => $tx->res->code) if $tx->result->is_error;
    push(@removed, $tx->res->json);
  }
  $c->render(openapi => {added => \@added, removed => \@removed});
}

sub test_order {
  my $c = shift;
  my $tx = $c->app->client->test_order;
  return $c->render(openapi => $tx->res->json, status => $tx->res->code);
}

1;

__END__

=encoding UTF-8
