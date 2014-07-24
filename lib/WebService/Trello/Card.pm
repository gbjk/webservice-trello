package WebService::Trello::Card;

use Moose;

use WebService::Trello;
use WebService::Trello::Board;

with qw(WebService::Trello::Role::PopulateFields);

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
    is => 'rw',
    isa => 'Str',
    );

has board => (
    is => 'ro',
    isa => 'WebService::Trello::Board',
    lazy_build => 1,
    );

has idBoard => (
    is => 'rw',
    isa => 'Str',
    );

sub api_type { 'cards' }
sub _build_board {
    my ($self) = @_;

    return WebService::Trello::Board->new( id => $self->idBoard );
    }

__PACKAGE__->meta->make_immutable;
