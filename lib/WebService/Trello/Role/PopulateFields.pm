package WebService::Trello::Role::PopulateFields;

use Moose::Role;

requires 'api_type';

sub get {
    my ($self) = @_;

    my $doc = $self->get_url($self->api_type, $self->id);
    foreach my $field (keys %$doc) {
        if (my $attr = $self->meta->get_attribute($field)) {
            next unless $attr->get_write_method;
            $self->$field($doc->{$field});
            }
        }
    }

1;
