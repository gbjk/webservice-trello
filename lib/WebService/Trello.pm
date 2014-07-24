package WebService::Trello;

use Moose;

use Config::Any;
use DDP;
use LWP::UserAgent;
use HTTP::Request;
use JSON;

has key => (
    is          => 'ro',
    isa         => 'Str',
    lazy_build  => 1,
    );

has token => (
    is          => 'ro',
    isa         => 'Str',
    lazy_build  => 1,
    );

has default_inbox_list_name => (
    is      => 'ro',
    isa     => 'Str',
    default => "Inbox"
    );

has ua => (
    is => 'ro',
    isa => 'LWP::UserAgent',
    lazy => 1,
    default => sub { LWP::UserAgent->new },
    handles => [qw/request/],
);

has url => (
    is => 'ro',
    isa => 'Str',
    default => 'https://api.trello.com/1/',
    );

has config => (
    isa         => 'HashRef',
    traits      => ['Hash'],
    lazy_build  => 1,
    handles     => {
        config  => 'accessor',
        },
    );

has config_filename => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    # Glob returns iterator if called in scalar context
    default => sub { (glob "~/.trello.conf")[0] }
    );

sub _build_config {
    my ($self) = @_;

    unless (-r $self->config_filename){
        say STDERR "[WARNING] Could not read config file: ".$self->config_filename;
        return {};
        }

    my $cfg = Config::Any->load_files({
        files   => [$self->config_filename],
        use_ext => 1,
        });

    my %config = map {
        my ($file, $file_config) = %$_;
        %$file_config;
        } @$cfg;

    return \%config;
    }

sub from_config_or_input {
    my ($self, $key) = @_;
    my $value = $self->config($key);
    unless ($value){
        die "I don't know how to prompt for stuff yet dude\n";
        }
    return $value;
    }

sub _build_key {
    return $_[0]->from_config_or_input("key");
    }

sub _build_token {
    return $_[0]->from_config_or_input("token");
    }

sub get_url {
    my ($self, $entity_type, $entity_id, $action) = @_;

    my $location = "$entity_type/$entity_id";
    $location .= "/$action" if $action;
    my $url = $self->url . "$location?" . join('&', map {$_ . "=" . $self->$_} qw/key token/);

    my $req = HTTP::Request->new(GET => $url);

    return $self->do_request($req);
    }

sub post_url {
    my ($self, $args, @action_uri) = (shift, pop, @_);

    my $url = $self->url.join "/", @action_uri;

    $args->{$_} = $self->$_ for qw/ key token /;

    my $req = HTTP::Request->new(POST => $url);
    my $content = join "&", map { "$_=$args->{$_}" } keys %$args;
    $req->content( $content );
    $req->content_type("application/x-www-form-urlencoded");

    return $self->do_request($req);
    }

sub do_request {
    my ($self, $req) = @_;

    my $resp = $self->request($req);

    unless ($resp->is_success) {
        die sprintf <<_EOF, $req->as_string, $resp->as_string;
Some kind of error occured.
Request:
%s

Response:
%s
_EOF
        }

    return from_json( $resp->content );
    }

__PACKAGE__->meta->make_immutable;
