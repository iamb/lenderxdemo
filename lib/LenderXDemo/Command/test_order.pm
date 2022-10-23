package LenderXDemo::Command::test_order;
use Mojo::Base 'Mojolicious::Command';

has description => 'submit a test order event';
has usage => sub { shift->extract_usage };

sub run {
  my $self = shift;
  my $client = OpenAPI::Client->new($self->app->spec_url, app => $self->app);
  my $tx = $client->test_order;
  die $tx->res->code.' '.$tx->res->message if $tx->result->is_error;

  #TODO: nicer output
  print $tx->res->body, "\n";
}

1;

__END__

=encoding UTF-8

=head1 SYNOPSIS

  Usage: lender_xdemo test_order
