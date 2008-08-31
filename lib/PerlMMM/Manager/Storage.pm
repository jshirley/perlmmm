package PerlMMM::Manager::Storage;

use Moose::Role;
use PerlMMM::Manager::Meeting;

requires 'parse_location';
requires 'parse_title';
requires 'parse_description';
requires 'parse_speaker';
requires 'parse_start_time';
requires 'parse_duration';

has 'meetings' => (
    isa         => 'ArrayRef',
    is          => 'rw',
    metaclass   => 'Collection::Array',
    lazy        => 1,
    default     => sub { shift->fetch_meetings }
);

sub fetch_meetings {
    my ( $self ) = @_;
    my $raw_list = $self->get_data;

    my @meetings = ();
    foreach my $data ( @$raw_list ) {
        eval {
            push @meetings, PerlMMM::Manager::Meeting->new(
                title       => $self->parse_title( $data ),
                description => $self->parse_description( $data ),
                speaker     => $self->parse_speaker( $data ),
                start_date  => $self->parse_start_time( $data ),
                duration    => $self->parse_duration( $data ),
                location    => $self->parse_location( $data ),
                storage     => $self
            );
        };
        if ( $@ ) {
            warn "Failed adding meeting, skipping bad data\n$@";
        }
    }

    return \@meetings;
}

1;
