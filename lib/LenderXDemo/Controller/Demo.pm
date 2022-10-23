package LenderXDemo::Controller::Demo;
use Mojo::Base 'Mojolicious::Controller';

sub add_event {
}

sub list_events {
  my $c = shift;
  die 'ok';
  my $tx = $c->client->list_events;
  $c->render(json => $tx->result->json);
}

sub update_event {
}

sub remove_event {
}

1;

__END__

=encoding UTF-8
