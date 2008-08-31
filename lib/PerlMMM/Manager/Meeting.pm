package PerlMMM::Manager::Meeting;

use Moose;

use MooseX::Types::DateTime qw/DateTime Duration/;
use Moose::Util::TypeConstraints;

has 'storage' => (
    isa => 'Object',
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

1;
