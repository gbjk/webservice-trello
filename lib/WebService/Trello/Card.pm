package WebService::Trello::Card;

use Moose;

use DDP;

use WebService::Trello;
use WebService::Trello::Board;
use WebService::Trello::List;

with qw(WebService::Trello::Role::PopulateFields);

has service => (
    isa => 'WebService::Trello',
    is  => 'ro',
    handles => [qw/get_url post_url default_inbox_list_name default_board_name/],
    lazy => 1,
    default => sub { WebService::Trello->new },
    );

has id => (
    is => 'rw',
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
    lazy_build  => 1,
    );

has list => (
    is => 'ro',
    isa => 'WebService::Trello::List',
    lazy_build => 1,
    );

has idList => (
    is => 'ro',
    isa => 'Str',
    lazy_build  => 1,
    );

has pos => (
    is => 'rw',
    isa => 'Num',
    );

sub api_type { 'cards' }
sub _build_board {
    my ($self) = @_;

    if ($self->has_idBoard){
        return WebService::Trello::Board->new( id => $self->idBoard );
        }

    return WebService::Trello::Board->get_by_name( $self->default_board_name );
    }

sub _build_idBoard {
    my ($self) = @_;
    return $self->has_board ? $self->board : undef;
    }

sub _build_list {
    return $_[0]->board->get_list_by_name( $_[0]->default_inbox_list_name );
    }

sub _build_idList {
    return ($_ = shift->list) ? $_->id : undef;
    }

sub create {
    my ($self) = @_;

    unless ($self->name){
        die "Errr. No. Name me. I must have a name\n";
        }

    unless ($self->idList){
        die "Must provide idList or list object\n";
        }

    my $doc = $self->post_url('cards', {
        # TODO - meta on attributes say which attributes we want,
        # and a role to get them out
        idList      => $self->idList,
        name        => $self->name,
        });

    $self->populate_fields($doc);
    return $self;
    }

sub add_comment {
    my ($self, $comment) = @_;

    $self->post_url('cards', $self->id, 'actions', 'comments', {
        text => $comment,
        });
    }
__PACKAGE__->meta->make_immutable;
