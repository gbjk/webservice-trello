package WebService::Trello::Card;

use Moose;

use DDP;

use WebService::Trello;
use WebService::Trello::Board;
use WebService::Trello::List;

has service => (
    isa => 'WebService::Trello',
    is  => 'ro',
    handles => [qw/get_url post_url default_inbox_list_name/],
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

sub _build_board {
    my ($self) = @_;

    if (my $board = $self->idBoard){
        return WebService::Trello::Board->new( id => $board );
        }
    return;
    }

sub _build_idBoard {
    return ($_ = shift->board) ? $_->id : undef;
    }

sub _build_list {
    return $_[0]->board->get_list_by_name( $_[0]->default_inbox_list_name );
    }

sub _build_idList {
    return ($_ = shift->list) ? $_->id : undef;
    }

sub create {
    my ($self) = @_;

    unless ($self->idBoard){
        die "Must provide idBoard or board object\n";
        }

    unless ($self->name){
        die "Errr. No. Name me. I must have a name\n";
        }

    unless ($self->idList){
        die "Must provide idList or list object\n";
        }

    $self->post_url('cards', {
        # TODO - meta on attributes say which attributes we want,
        # and a role to get them out
        idList      => $self->idList,
        name        => $self->name,
        });

    return;
    }

sub get {
    my ($self) = @_;

    my $doc = $self->get_url('cards', $self->id);
    }

__PACKAGE__->meta->make_immutable;
