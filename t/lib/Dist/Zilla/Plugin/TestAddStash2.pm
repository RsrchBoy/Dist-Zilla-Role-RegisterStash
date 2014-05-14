package Dist::Zilla::Plugin::TestAddStash2;

use Moose;
use namespace::autoclean;

with
    'Dist::Zilla::Role::BeforeRelease',
    'Dist::Zilla::Role::RegisterStash',
    ;

use Test::More;

sub before_release {
    my $self = shift @_;

    # add stash
    pass 'in before_release()';
    $self->_register_or_retrieve_stash('%TestStash');
    return;
}


__PACKAGE__->meta->make_immutable;
!!42;
__END__
