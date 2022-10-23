package LenderXDemo::Client;
use Mojo::Base 'OpenAPI::Client';
use Carp 'croak';

has _token => sub { +{} };

has api_key => sub { croak 'api_key not set' };

has api_secret => sub { croak 'api_secret not set' };

has auth_url => sub { croak 'auth url not set' };

sub _tx_error {
  my $tx = shift;
  my $j = $tx->res->json;
  if (ref($j) eq 'HASH' and my $e = $j->{errors}) {
    return join("\n", map { ref($_) ? $_->{message} : $_ } @$e);
  }
  return $tx->res->code . ' ' .$tx->res->message;
}

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  $self->ua->proxy->detect;
  $self->ua->transactor->name('LenderXDemo');
  $self->on(after_build_tx => sub {
    my ($client, $tx) = @_;
    # NB: blocking:
    my $token = $client->token;
    $tx->req->headers->header(Authorization => "$token->{token_type} $token->{access_token}");
  });
  return $self;
}

sub token {
  my $self = shift;
  my $token = $self->_token;
  # NB: arbitrarily chosen 15 second refresh-early period
  unless ($token->{expires} || 0 > time - 15) {
    my $url = $self->auth_url->clone;
    $url->userinfo($self->api_key.':'.$self->api_secret);

    my $tx = $self->ua->post($url, form => {grant_type => 'client_credentials'});
    die _tx_error($tx) if $tx->result->is_error;
    my $token = $tx->res->json;

    die 'invalid token response (no json)' unless $token;
    die 'invalid token response (not hash)' unless ref($token) eq 'HASH';

    $token->{created} = time;
    $token->{expires} = $token->{expires_in} + $token->{created};
    $self->_token($token);
    return $token;
  }
  return $token;
}

1;

__END__

=encoding UTF-8

=head1 DESCRIPTION

LenderX sandbox client for demo

=head1 METHODS

=head2 token

  my $token = $client->token;

Return a cached token if not expired, or get a new token.
