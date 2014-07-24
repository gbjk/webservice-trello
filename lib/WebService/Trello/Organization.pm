package WebService::Trello::Organization;

use Moose;

use WebService::Trello;
use WebService::Trello::Board;

with qw(WebService::Trello::Role::PopulateFields);

has id => (
    is => 'ro',
    isa => 'Str',
    default => 'thermeon',
    );

has service => (
    isa => 'WebService::Trello',
    is  => 'ro',
    handles => [qw/get_url/],
    lazy => 1,
    default => sub { WebService::Trello->new },
    );

sub api_type { 'organizations' }

sub get_boards {
    my ($self) = @_;

    my $doc = $self->get_url('organizations', $self->id, 'boards');

    my @boards;
    foreach my $board (@$doc) {
        push @boards, WebService::Trello::Board->new( %$board );
        }

    return @boards;
    }

__PACKAGE__->meta->make_immutable;
