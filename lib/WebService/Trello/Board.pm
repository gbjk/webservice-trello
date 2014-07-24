package WebService::Trello::Board;

use Moose;

use WebService::Trello;
use WebService::Trello::Card;
use WebService::Trello::Organization;
use WebService::Trello::List;
use DDP;

has id => (
    is => 'ro',
    isa => 'Str',
    default => '53d11206f52787e522bd21a2',
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

sub get {
    my ($self) = @_;

    my $doc = $self->get_url('boards', $self->id);
    }

sub get_by_name {
    my ($class, $name) = @_;
    my $self = $class->new;

    my @boards = WebService::Trello::Organization->new->get_boards;

    my ($board) = grep {$_->name eq $name} @boards;

    return $board;
    }

sub get_lists {
    my ($self) = @_;

    my $doc = $self->get_url('board', $self->id, 'lists');
    my @lists = map { WebService::Trello::List->new( %$_ ) } @$doc;

    return @lists;
    }

sub get_list_by_name {
    my ($self, $name) = @_;
    my @lists = $self->get_lists;
    my ($list) = grep {$_->name eq $name} @lists;
    return $list;
    }

sub get_cards {
    my ($self) = @_;

    my $doc = $self->get_url('board', $self->id, 'cards');

    my @cards;
    foreach my $card (@$doc) {
        push @cards, WebService::Trello::Card->new( %$card );
        }

    return @cards;
    }

__PACKAGE__->meta->make_immutable;
