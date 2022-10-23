package LenderXDemo;
use Mojo::Base 'Mojolicious';
use LenderXDemo::Client;
use Mojo::URL;
use Mojo::Util qw(sha1_sum steady_time);
use OpenAPI::Client;

has api_key => sub {
  my $self = shift;
  return $ENV{LENDERX_API_KEY}
         || $self->config('lenderx_api_key')
         || die 'please configure lenderx_api_key or set LENDERX_API_KEY';
};

has api_secret => sub {
  my $self = shift;
  return $ENV{LENDERX_API_SECRET}
         || $self->config('lenderx_api_secret')
         || die 'please configure lenderx_api_secret or set LENDERX_API_SECRET';
};

has client => sub {
  my $self = shift;
  return LenderXDemo::Client->new(
    $self->lenderx_spec_url,
    api_key => $self->api_key,
    api_secret => $self->api_secret,
    auth_url => $self->auth_url,
  );
};

has auth_url => sub {
  my $self = shift;
  my $url = $ENV{LENDERX_AUTH_URL}
            || $self->config('lenderx_auth_url')
            || 'https://idp.sandbox1.lenderx-labs.com/oauth/access_token';
  $url = Mojo::URL->new($url);
  return $url;
};

has lenderx_spec_url => sub {
  my $self = shift;
  my $url = $ENV{LENDERX_SPEC_FILE}
            || $self->config('lenderx_spec_url')
            || $self->home->child('appraisal.json');
  $url = Mojo::URL->new($url);
};

has spec_url => sub {
  my $self = shift;
  my $url = $ENV{API_SPEC_FILE}
            || $self->config('api_spec_url')
            || $self->home->child('api-v1.json');
  $url = Mojo::URL->new($url);
};

sub startup {
  my $self = shift;
  my $config = $self->plugin('NotYAMLConfig');

  $self->secrets($config->{secrets} || [sha1_sum($$ . steady_time . rand)]);

  push(@{$self->commands->namespaces}, 'LenderXDemo::Command');

  my $openapi_conf = $config->{openapi} || {};
  $openapi_conf->{url} = $self->spec_url;
  $self->plugin(OpenAPI => $openapi_conf);

  $self->helper('reply.exception' => sub { shift->reply->json_exception(@_) });
  $self->helper('reply.not_found' => sub { shift->reply->json_not_found(@_) });

}

1;
