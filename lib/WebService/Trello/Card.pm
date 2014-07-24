package WebService::Trello::Card;

use Moose;

use WebService::Trello;
use WebService::Trello::Board;

has service => (
    isa => 'WebService::Trello',
    is  => 'ro',
    handles => [qw/get_url/],
    lazy => 1,
    default => sub { WebService::Trello->new },
    );

has id => (
    is => 'ro',
    isa => 'Str',
    );

has name => (
    is => 'ro',
    isa => 'Str',
    );

has board => (
    is => 'ro',
    isa => 'WebService::Trello::Board',
    lazy_build => 1,
    );

has idBoard => (
    is => 'ro',
    isa => 'Str',
    );

sub _build_board {
    my ($self) = @_;

    return WebService::Trello::Board->new( id => $self->idBoard );
    }

sub get {
    my ($self) = @_;

    my $doc = $self->get_url('cards', $self->id);
    }

__PACKAGE__->meta->make_immutable;
