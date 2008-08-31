package PerlMMM::Manager::Meeting;

use Moose;

use PerlMMM::Manager::Types qw(Stores Storage);
use MooseX::Types::DateTime qw(DateTime Duration);

use Moose::Util::TypeConstraints;

has 'stores' => (
    isa         => 'Stores',
    is          => 'rw',
    coerce      => 1,
);

has 'id' => (
    isa => 'Int',
    is  => 'rw',
);

has 'speaker' => (
    isa => 'Data::Microformat::hCard',
    is  => 'rw',
);

has 'start_date' => ( 
    isa => 'DateTime',
    is  => 'rw',
    coerce => 1
);

has 'duration'   => ( 
    isa     => Duration,
    is      => 'rw',
    coerce  => 1
);

has 'title' => ( 
    isa => 'Str',
    is  => 'rw'
);

has 'description' => ( 
    isa => 'Str',
    is  => 'rw'
);

# Need to subtype this
has 'location' => ( 
    isa   => 'Data::Microformat::adr',
    is    => 'rw',
);

sub as_string {
    my ( $self ) = @_;
    my $hcal = Data::Microformat::hCal->new;
        $hcal->dtstart( $self->start_date->iso8601 );
        $hcal->dtend($self->start_date->add( $self->duration )->iso8601);

    join("\n",
        $self->title,
        $self->speaker->to_hcard,
        $self->location->to_hcard,
        $hcal->to_hcard,
        $self->description,
    );
}

sub generate_summary {
    my ( $self ) = @_;
    my $hcal = Data::Microformat::hCal->new;
        $hcal->dtstart( $self->start_date->iso8601 );
        $hcal->dtend($self->start_date->add( $self->duration )->iso8601);

    join("\n",
        "<h1>" . $self->title . "</h1>",
        $self->speaker->to_hcard,
        $self->location->to_hcard,
        $hcal->to_hcard,
    );
}


sub save {
    my ( $self ) = @_;
    die "Can't save without at least one store\n"
        unless @{ $self->stores || [] };
    foreach my $store ( @{ $self->stores } ) {
        $store->save( $self );
    }
}

1;
