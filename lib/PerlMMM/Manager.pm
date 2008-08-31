package PerlMMM::Manager;

use Carp;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::AttributeHelpers;

with 'MooseX::Object::Pluggable';

#use PerlMMM::Manager::Types qw(Stores);
subtype 'Storage' => as   'Object';
subtype 'Stores'  => as   'ArrayRef[Storage]';
coerce  'Stores'  => from 'HashRef[HashRef]' => via {
    my $stores = [];
    foreach my $type ( keys %$_ ) {
        eval { 
            Class::MOP::load_class("PerlMMM::Manager::Storage::$type");
            push @$stores, 
                "PerlMMM::Manager::Storage::$type"->new( $_->{$type} );
        };
        if ( $@ ) { carp "Failed to load storage class $type:\n$@"; }
    }
    return $stores;
};

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
