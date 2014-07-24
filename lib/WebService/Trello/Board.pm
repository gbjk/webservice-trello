package WebService::Trello::Board;

use Moose;

use WebService::Trello;
use WebService::Trello::Card;

has id => (
    is => 'ro',
    isa => 'Str',
    default => '53d11206f52787e522bd21a2',
    );

has name => (
    is => 'rw',
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
    foreach my $field (keys %$doc) {
        if (my $attr = $self->meta->get_attribute($field)) {
            next unless $attr->get_write_method;
            $self->$field($doc->{$field});
            }
        }
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
