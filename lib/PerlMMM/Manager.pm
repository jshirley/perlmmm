package PerlMMM::Manager;

use Carp;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::AttributeHelpers;

with 'MooseX::Object::Pluggable';

use PerlMMM::Manager::Types qw(Stores Storage);

has 'stores' => (
    isa         => 'Stores',
    is          => 'rw',
    coerce      => 1,
);

has 'meetings' => (
    isa => 'ArrayRef',
    is  => 'rw',
    metaclass => 'Collection::Array',
    lazy => 1,
    default => sub { shift->fetch_meetings }
);

sub fetch_meetings {
    my ( $self ) = @_;
    my @meetings;
    foreach my $store ( @{ $self->stores } ) {
        push @meetings, @{ $store->fetch_meetings };
    }

    return \@meetings;
}

1;
