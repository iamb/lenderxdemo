package LenderXDemo::Command::subscriptions;
use Mojo::Base 'Mojolicious::Command';
use Mojo::Util 'getopt';

sub _cmd_list {
  my ($self, $client, @args) = @_;

  my $tx = $client->list_events;
  die $tx->res->code.' '.$tx->res->message if $tx->result->is_error;

  #TODO: nicer output
  print $tx->res->body, "\n";
}

sub _cmd_add {
  my ($self, $client, @args) = @_;
  getopt(\@args,
    my $opt = {},
    'event|e:s@',
    'url|u:s',
  ) or die $self->usage;
  $opt->{event} ||= [];
  die "url required\n".$self->usage unless $opt->{url};
  die "at least one event required\n".$self->usage unless @{$opt->{event}};

  my $tx = $client->manage_events({} => json => {
    add => [{
      url => $opt->{url},
      events => $opt->{event},
    }],
  });
  die $tx->res->code.' '.$tx->res->message if $tx->result->is_error;

  #TODO: nicer output
  print $tx->res->body, "\n";
}

sub _cmd_remove {
  my ($self, $client, @args) = @_;
  getopt(\@args,
    my $opt = {},
    'id|i:s@',
  ) or die $self->usage;
  $opt->{id} ||= [];
  die "at least one event id required\n".$self->usage unless @{$opt->{id}};

  my $tx = $client->manage_events({} => json => { remove => $opt->{id} });
  die $tx->res->code.' '.$tx->res->message if $tx->result->is_error;

  #TODO: nicer output
  print $tx->res->body, "\n";
}

my %cmd_dispatch = (
  list => \&_cmd_list,
  add => \&_cmd_add,
  remove => \&_cmd_remove,
);

sub run {
  my ($self, $cmd, @args) = @_;
  die "missing command\n".$self->usage unless $cmd;
  my $dispatch = $cmd_dispatch{$cmd};
  die "invalid command\n".$self->usage unless $dispatch;
  my $client = OpenAPI::Client->new($self->app->spec_url, app => $self->app);
  $self->$dispatch($client, @args);
}

1;

__END__

=encoding UTF-8

=head1 SYNOPSIS

  Usage: lender_xdemo subscriptions list
         lender_xdemo subscriptions add -u <url> -e <event> [-e <event> ..]
         lender_xdemo subscriptions remove -i <event_id> [-i <event_id> ..]
