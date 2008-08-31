package PerlMMM::Manager::Storage;

use Moose::Role;
use PerlMMM::Manager::Meeting;

requires 'parse_id';
requires 'parse_location';
requires 'parse_title';
requires 'parse_description';
requires 'parse_speaker';
requires 'parse_start_time';
requires 'parse_duration';
requires 'save';

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
            # TODO: We need to query other stores for meetings based on its
            # UUID, then we can just add ourself into the stores.  This means
            # that we'll have to call back to the ::Manager instance to add
            # the meeting though and then let it do the work.  Or, just let it
            # merge the stores and meetings in Manager->fetch_meetings
            push @meetings, PerlMMM::Manager::Meeting->new(
                id          => $self->parse_id( $data ),
                title       => $self->parse_title( $data ),
                description => $self->parse_description( $data ),
                speaker     => $self->parse_speaker( $data ),
                start_date  => $self->parse_start_time( $data ),
                duration    => $self->parse_duration( $data ),
                location    => $self->parse_location( $data ),
                stores      => [ $self ]
            );
        };
        if ( $@ ) {
            warn "Failed adding meeting, skipping bad data\n$@";
        }
    }

    return \@meetings;
}

1;
