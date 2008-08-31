package PerlMMM::Manager::Storage::MT;

use Moose;
use Net::MovableType;

use DateTime::Format::ISO8601;

use Data::Microformat::hCard;
use Data::Microformat::hCal;
use Data::Microformat::adr;

with 'PerlMMM::Manager::Storage';

has 'url' => (
    isa => 'Str',
    is  => 'rw',
    required => 1
);

has 'username' => (
    isa => 'Str',
    is  => 'rw',
    required => 1
);

has 'password' => (
    isa => 'Str',
    is  => 'rw',
    required => 1
);

has 'client' => (
    isa => 'Object',
    is  => 'rw',
    where => sub { shift->isa('Net::MovableType'); }
);

has 'categories' => (
    isa         => 'ArrayRef',
    is          => 'rw',
    metaclass   => 'Collection::Array',
);

sub BUILD {
    my ( $self, $params ) = @_;
    unless ( $self->client ) {
        $self->client( Net::MovableType->new( $self->url ) );
        $self->client->username($self->username);
        $self->client->password($self->password);
    }
}

sub get_data { 
    my ( $self ) = @_;
    $self->client->getRecentPosts(1);
}

sub parse_id {
    my ( $self, $post ) = @_;
    $post->{postid};
}

sub parse_location { 
    my ( $self, $post ) = @_;
    my $adr = Data::Microformat::adr->parse( $post->{description} );
    unless ( $adr ) {
        $adr = Data::Microformat::adr->new;
        $adr->street_address('1000 Clay St');
        $adr->locality('Portland');
        $adr->region('OR');
        $adr->postal_code('98123');
        $adr->country_name('USA');
    }
    return $adr;
}

sub parse_title { 
    my ( $self, $post ) = @_;
    $post->{title};
}

sub parse_description {
    my ( $self, $post ) = @_;
    $post->{mt_text_more};
}

sub parse_speaker { 
    my ( $self, $post ) = @_;
    my $card = Data::Microformat::hCard->parse( $post->{description} );
    unless ( $card ) {
        $card = Data::Microformat::hCard->new;
        $card->fn("TBD");
        $card->nickname("To Be Determined");
    }
    return $card;
}

sub parse_start_time {
    my ( $self, $post ) = @_;
    my $cal = Data::Microformat::hCal->parse( $post->{description} );

    my $time;
    if ( $cal ) {
        $time = DateTime::Format::ISO8601->parse_datetime( $cal->dtstart );
    }
    return $time;
}

sub parse_duration { 
    my ( $self, $post ) = @_;
    my $cal = Data::Microformat::hCal->parse( $post->{description} );
    if ( $cal ) {
        my $start_time = DateTime::Format::ISO8601->parse_datetime( $cal->dtstart );
        my $end_time = DateTime::Format::ISO8601->parse_datetime( $cal->dtend );
        return $end_time - $start_time;
    }
    return undef;
}

sub save {
    my ( $self, $meeting ) = @_;

    my $entry = {
        title           => $meeting->title,
        description     => $meeting->generate_summary,
        mt_text_more    => $meeting->description,
    };

    if ( $meeting->id ) {
        my $page = $self->client->getPost( $meeting->id );
        if ( $page ) {
            $self->client->editPost($meeting->id, $entry);
            return;
        }
        # Couldn't fetch if we got here, so move on.
    }
    my $id = $self->client->newPost($entry, 0);
    unless ( $id ) {
        die "Failed posting entry\n";
    }
    if ( $self->categories and @{$self->categories} ) {
        $self->client->setPostCategories($id, $self->categories);
    }
    $self->client->publishPost($id);
}

1;
