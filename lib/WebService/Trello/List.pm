package WebService::Trello::List;

use Moose;

use WebService::Trello;
use WebService::Trello::Card;
use WebService::Trello::Organization;
use WebService::Trello::Board;
use DDP;

has id => (
    is => 'ro',
    isa => 'Str',
    );

has idBoard => (
    is  => 'ro',
    isa => 'Str',
    );

has name => (
    is => 'ro',
    isa => 'Str',
    );

has service => (
    isa => 'WebService::Trello',
    is  => 'ro',
    handles => [qw/get_url/],
    lazy => 1,
    default => sub { WebService::Trello->new },
    );

__PACKAGE__->meta->make_immutable;
