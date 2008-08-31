package PerlMMM::Manager::Types;

use Carp;

use strict;
use warnings;

use MooseX::Types::Moose qw(ArrayRef Object HashRef);
use MooseX::Types -declare => [ qw( Stores Storage ) ];

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


1;
